package com.example.saphcm.config;

import com.example.saphcm.entity.*;
import com.example.saphcm.enums.*;
import com.example.saphcm.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Configuration
@RequiredArgsConstructor
public class DataSeeder {
    private final RoleRepository roleRepository;
    private final DepartmentRepository departmentRepository;
    private final EmployeeRepository employeeRepository;
    private final UserRepository userRepository;
    private final LeaveRequestRepository leaveRepository;
    private final AttendanceRepository attendanceRepository;
    private final PayrollRepository payrollRepository;
    private final JobOfferRepository jobOfferRepository;
    private final CandidateRepository candidateRepository;
    private final PerformanceReviewRepository performanceRepository;
    private final TrainingRepository trainingRepository;
    private final TrainingEnrollmentRepository enrollmentRepository;
    private final ReportRepository reportRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner seedData() {
        return args -> {
            if (userRepository.count() > 0) return;

            Map<RoleName, Role> roles = new java.util.EnumMap<>(RoleName.class);
            for (RoleName roleName : RoleName.values()) {
                roles.put(roleName, roleRepository.save(new Role(roleName)));
            }

            Department direction = departmentRepository.save(new Department("Direction", "Pilotage global et gouvernance"));
            Department rh = departmentRepository.save(new Department("Ressources Humaines", "Gestion RH, paie et formation"));
            Department it = departmentRepository.save(new Department("IT", "Solutions digitales et integration SAP"));
            Department finance = departmentRepository.save(new Department("Finance", "Comptabilite et controle de gestion"));
            Department ops = departmentRepository.save(new Department("Operations", "Production et support operationnel"));

            Employee admin = employee("ADM-001", "Sofia", "Haddad", "Administratrice Systeme", direction, null, "admin@test.com", "0600000001", "Rabat", LocalDate.of(2018, 1, 8), ContractType.CDI, new BigDecimal("45000"), 30);
            Employee manager = employee("MGR-001", "Youssef", "El Amrani", "Manager IT", it, admin, "manager@test.com", "0600000002", "Casablanca", LocalDate.of(2019, 3, 12), ContractType.CDI, new BigDecimal("32000"), 26);
            Employee hr = employee("HR-001", "Nadia", "Benali", "Responsable RH", rh, admin, "hr@test.com", "0600000003", "Rabat", LocalDate.of(2020, 5, 18), ContractType.CDI, new BigDecimal("30000"), 26);
            Employee employee = employee("EMP-001", "Amine", "Berrada", "Developpeur Flutter", it, manager, "employee@test.com", "0600000004", "Casablanca", LocalDate.of(2022, 9, 1), ContractType.CDI, new BigDecimal("18000"), 24);
            Employee analyst = employee("EMP-002", "Salma", "Idrissi", "Analyste Fonctionnelle SAP HCM", it, manager, "salma.idrissi@test.com", "0600000005", "Marrakech", LocalDate.of(2021, 11, 15), ContractType.CDI, new BigDecimal("21000"), 24);
            Employee accountant = employee("EMP-003", "Karim", "Fassi", "Comptable Paie", finance, hr, "karim.fassi@test.com", "0600000006", "Fes", LocalDate.of(2023, 2, 6), ContractType.CDD, new BigDecimal("15000"), 20);
            Employee opsLead = employee("MGR-002", "Imane", "Tazi", "Manager Operations", ops, admin, "imane.tazi@test.com", "0600000007", "Tanger", LocalDate.of(2017, 6, 20), ContractType.CDI, new BigDecimal("29000"), 26);
            Employee operator = employee("EMP-004", "Mehdi", "Alaoui", "Charge Support RH", ops, opsLead, "mehdi.alaoui@test.com", "0600000008", "Agadir", LocalDate.of(2024, 1, 10), ContractType.CDI, new BigDecimal("12000"), 22);

            user("admin@test.com", roles.get(RoleName.ADMIN), admin);
            user("manager@test.com", roles.get(RoleName.MANAGER), manager);
            user("hr@test.com", roles.get(RoleName.HR), hr);
            user("employee@test.com", roles.get(RoleName.EMPLOYEE), employee);

            seedLeaves(employee, analyst, accountant, manager, hr);
            seedAttendance(employee, analyst, manager, hr, accountant, operator);
            seedPayroll(List.of(admin, manager, hr, employee, analyst, accountant, opsLead, operator));
            seedRecruitment(it, rh, finance);
            seedPerformance(employee, analyst, accountant, manager, hr);
            seedTraining(employee, analyst, accountant, operator);
            seedReports();
        };
    }

    private Employee employee(String number, String first, String last, String job, Department dept, Employee manager, String email, String phone, String address, LocalDate hireDate, ContractType type, BigDecimal salary, int balance) {
        Employee e = new Employee();
        e.setEmployeeNumber(number);
        e.setFirstName(first);
        e.setLastName(last);
        e.setJobTitle(job);
        e.setDepartment(dept);
        e.setManager(manager);
        e.setEmail(email);
        e.setPhone(phone);
        e.setAddress(address);
        e.setHireDate(hireDate);
        e.setContractType(type);
        e.setBaseSalary(salary);
        e.setAnnualLeaveBalance(balance);
        e.setActive(true);
        e.setAvatarUrl("https://ui-avatars.com/api/?name=" + first + "+" + last + "&background=0a6ed1&color=fff");
        return employeeRepository.save(e);
    }

    private void user(String email, Role role, Employee employee) {
        User user = new User(email, passwordEncoder.encode("password"));
        user.setRoles(Set.of(role));
        user.setEmployee(employee);
        userRepository.save(user);
    }

    private void seedLeaves(Employee employee, Employee analyst, Employee accountant, Employee manager, Employee hr) {
        leave(employee, LeaveType.CONGE_ANNUEL, LocalDate.now().plusDays(5), LocalDate.now().plusDays(9), "Vacances familiales", LeaveStatus.EN_ATTENTE, null);
        leave(employee, LeaveType.CONGE_MALADIE, LocalDate.now().minusDays(20), LocalDate.now().minusDays(18), "Certificat medical", LeaveStatus.APPROUVE, manager);
        leave(analyst, LeaveType.CONGE_EXCEPTIONNEL, LocalDate.now().plusDays(12), LocalDate.now().plusDays(13), "Evenement familial", LeaveStatus.EN_ATTENTE, null);
        leave(accountant, LeaveType.CONGE_ANNUEL, LocalDate.now().minusDays(30), LocalDate.now().minusDays(26), "Repos", LeaveStatus.REFUSE, hr);
    }

    private void leave(Employee employee, LeaveType type, LocalDate start, LocalDate end, String reason, LeaveStatus status, Employee approvedBy) {
        LeaveRequest leave = new LeaveRequest();
        leave.setEmployee(employee);
        leave.setType(type);
        leave.setStartDate(start);
        leave.setEndDate(end);
        leave.setDays((int) (java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1));
        leave.setReason(reason);
        leave.setStatus(status);
        leave.setApprovedBy(approvedBy);
        leave.setCreatedAt(LocalDateTime.now().minusDays(2));
        if (status != LeaveStatus.EN_ATTENTE) leave.setDecisionAt(LocalDateTime.now().minusDays(1));
        leaveRepository.save(leave);
    }

    private void seedAttendance(Employee... employees) {
        for (int i = 0; i < employees.length; i++) {
            // L'employe de test principal n'a pas encore pointe aujourd'hui,
            // afin de permettre une demonstration entree/sortie en direct.
            if (i > 0) {
                Attendance today = new Attendance();
                today.setEmployee(employees[i]);
                today.setDate(LocalDate.now());
                today.setCheckInTime(LocalTime.of(8, 45).plusMinutes((long) (i % 3) * 10));
                today.setStatus(i % 3 == 2 ? AttendanceStatus.EN_RETARD : AttendanceStatus.PRESENT);
                attendanceRepository.save(today);
            }

            Attendance yesterday = new Attendance();
            yesterday.setEmployee(employees[i]);
            yesterday.setDate(LocalDate.now().minusDays(1));
            yesterday.setCheckInTime(LocalTime.of(8, 50));
            yesterday.setCheckOutTime(LocalTime.of(17, 35));
            yesterday.setTotalHours(new BigDecimal("8.75"));
            yesterday.setStatus(AttendanceStatus.SORTI);
            attendanceRepository.save(yesterday);
        }
    }

    private void seedPayroll(List<Employee> employees) {
        for (Employee e : employees) {
            payroll(e, "2026-04", PayrollStatus.PAYE, LocalDate.of(2026, 4, 30));
            payroll(e, "2026-05", PayrollStatus.EN_ATTENTE, LocalDate.of(2026, 5, 31));
        }
    }

    private void payroll(Employee e, String month, PayrollStatus status, LocalDate date) {
        Payroll p = new Payroll();
        p.setEmployee(e);
        p.setMonth(month);
        p.setBaseSalary(e.getBaseSalary());
        p.setBonuses(e.getBaseSalary().multiply(new BigDecimal("0.08")));
        p.setOvertime(new BigDecimal("750"));
        p.setDeductions(e.getBaseSalary().multiply(new BigDecimal("0.05")));
        p.setCharges(e.getBaseSalary().multiply(new BigDecimal("0.12")));
        p.setGrossSalary(p.getBaseSalary().add(p.getBonuses()).add(p.getOvertime()));
        p.setNetSalary(p.getGrossSalary().subtract(p.getDeductions()).subtract(p.getCharges()));
        p.setPaymentDate(date);
        p.setStatus(status);
        payrollRepository.save(p);
    }

    private void seedRecruitment(Department it, Department rh, Department finance) {
        JobOffer dev = job("Developpeur Flutter/Spring Boot", it, ContractType.CDI, JobOfferStatus.OUVERTE, "Application RH mobile/web connectee a SAP HCM");
        JobOffer consultant = job("Consultant SAP HCM Junior", rh, ContractType.CDI, JobOfferStatus.OUVERTE, "Parametrage processus RH et support utilisateurs");
        job("Analyste Paie", finance, ContractType.CDD, JobOfferStatus.FERMEE, "Support paie et reporting mensuel");
        candidate(dev, "Rania Belkacem", "rania.belkacem@example.com", CandidateStatus.ENTRETIEN);
        candidate(dev, "Omar Saidi", "omar.saidi@example.com", CandidateStatus.RECUE);
        candidate(consultant, "Lina Mourad", "lina.mourad@example.com", CandidateStatus.ACCEPTEE);
    }

    private JobOffer job(String title, Department dept, ContractType type, JobOfferStatus status, String desc) {
        JobOffer job = new JobOffer();
        job.setTitle(title);
        job.setDepartment(dept);
        job.setContractType(type);
        job.setPublicationDate(LocalDate.now().minusDays(7));
        job.setStatus(status);
        job.setDescription(desc);
        return jobOfferRepository.save(job);
    }

    private void candidate(JobOffer job, String name, String email, CandidateStatus status) {
        Candidate c = new Candidate();
        c.setJobOffer(job);
        c.setFullName(name);
        c.setEmail(email);
        c.setCvUrl("/mock/cv/" + name.toLowerCase().replace(" ", "-") + ".pdf");
        c.setStatus(status);
        candidateRepository.save(c);
    }

    private void seedPerformance(Employee employee, Employee analyst, Employee accountant, Employee manager, Employee hr) {
        review(employee, manager, "S1-2026", 4, PerformanceStatus.BROUILLON, "Bonne progression sur Flutter et API REST");
        review(analyst, manager, "S1-2026", 5, PerformanceStatus.VALIDEE, "Excellente comprehension SAP HCM");
        review(accountant, hr, "S1-2026", 3, PerformanceStatus.BROUILLON, "Ameliorer les delais de reporting paie");
    }

    private void review(Employee employee, Employee manager, String period, int score, PerformanceStatus status, String comment) {
        PerformanceReview r = new PerformanceReview();
        r.setEmployee(employee);
        r.setManager(manager);
        r.setPeriod(period);
        r.setObjective1("Qualite de livraison");
        r.setObjective2("Collaboration equipe");
        r.setObjective3("Montee en competence SAP HCM");
        r.setScore(score);
        r.setComment(comment);
        r.setStatus(status);
        performanceRepository.save(r);
    }

    private void seedTraining(Employee employee, Employee analyst, Employee accountant, Employee operator) {
        Training flutter = training("Flutter UI/UX RH", "Concevoir des interfaces RH responsives", 16, "Cabinet Digital Academy", TrainingStatus.EN_COURS, LocalDate.now().minusDays(2), LocalDate.now().plusDays(3));
        Training security = training("Spring Security JWT", "Securiser les API REST RH", 12, "TechSec Maroc", TrainingStatus.PLANIFIEE, LocalDate.now().plusDays(10), LocalDate.now().plusDays(12));
        Training sap = training("Introduction SAP HCM", "Objets metier RH et integration via SAP Business Accelerator Hub", 20, "SAP Partner Demo", TrainingStatus.TERMINEE, LocalDate.now().minusDays(40), LocalDate.now().minusDays(35));
        enroll(flutter, employee, 60);
        enroll(flutter, analyst, 75);
        enroll(security, employee, 0);
        enroll(sap, accountant, 100);
        enroll(sap, operator, 100);
    }

    private Training training(String title, String desc, int hours, String trainer, TrainingStatus status, LocalDate start, LocalDate end) {
        Training t = new Training();
        t.setTitle(title);
        t.setDescription(desc);
        t.setDurationHours(hours);
        t.setTrainer(trainer);
        t.setStatus(status);
        t.setStartDate(start);
        t.setEndDate(end);
        return trainingRepository.save(t);
    }

    private void enroll(Training training, Employee employee, int progress) {
        TrainingEnrollment e = new TrainingEnrollment();
        e.setTraining(training);
        e.setEmployee(employee);
        e.setProgressPercent(progress);
        enrollmentRepository.save(e);
    }

    private void seedReports() {
        Report r = new Report();
        r.setType(ReportType.LEAVES);
        r.setTitle("Rapport conges demo");
        r.setPayloadSummary("Rapport genere a la demande depuis /api/reports/leaves");
        reportRepository.save(r);
    }
}
