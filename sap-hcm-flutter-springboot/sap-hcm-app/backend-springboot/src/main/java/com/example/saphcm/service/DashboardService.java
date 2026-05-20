package com.example.saphcm.service;

import com.example.saphcm.dto.DashboardStatsDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.enums.AttendanceStatus;
import com.example.saphcm.enums.LeaveStatus;
import com.example.saphcm.enums.PayrollStatus;
import com.example.saphcm.enums.PerformanceStatus;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.enums.TrainingStatus;
import com.example.saphcm.repository.*;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {
    private final EmployeeRepository employeeRepository;
    private final DepartmentRepository departmentRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRequestRepository leaveRepository;
    private final PayrollRepository payrollRepository;
    private final CandidateRepository candidateRepository;
    private final TrainingRepository trainingRepository;
    private final PerformanceReviewRepository performanceRepository;
    private final CurrentUserService current;

    public DashboardStatsDto stats() {
        boolean hrAdmin = current.hasAnyRole(RoleName.HR, RoleName.ADMIN);
        boolean manager = current.hasRole(RoleName.MANAGER);
        Employee me = current.currentEmployee();
        Set<Long> visibleEmployeeIds = visibleEmployeeIds(hrAdmin, manager, me);

        BigDecimal payrollMass = hrAdmin ? payrollRepository.sumNetSalaryByStatus(PayrollStatus.PAYE) : BigDecimal.ZERO;
        if (payrollMass == null) payrollMass = BigDecimal.ZERO;

        long presentToday = attendanceRepository.findAll().stream()
                .filter(a -> visibleEmployeeIds.contains(a.getEmployee().getId()))
                .filter(a -> a.getDate().equals(LocalDate.now()))
                .filter(a -> List.of(AttendanceStatus.PRESENT, AttendanceStatus.EN_RETARD, AttendanceStatus.SORTI).contains(a.getStatus()))
                .count();

        long pendingLeaves = leaveRepository.findAll().stream()
                .filter(l -> visibleEmployeeIds.contains(l.getEmployee().getId()))
                .filter(l -> l.getStatus() == LeaveStatus.EN_ATTENTE)
                .count();

        long approvedLeaves = leaveRepository.findAll().stream()
                .filter(l -> visibleEmployeeIds.contains(l.getEmployee().getId()))
                .filter(l -> l.getStatus() == LeaveStatus.APPROUVE)
                .count();

        return DashboardStatsDto.builder()
                .totalEmployees(visibleEmployeeIds.size())
                .presentToday(presentToday)
                .pendingLeaves(pendingLeaves)
                .approvedLeaves(approvedLeaves)
                .simulatedPayrollMass(payrollMass)
                .recruitmentCandidates(hrAdmin ? candidateRepository.count() : 0)
                .activeTrainings(trainingRepository.countByStatusIn(List.of(TrainingStatus.PLANIFIEE, TrainingStatus.EN_COURS)))
                .pendingReviews(hrAdmin || manager ? performanceRepository.countByStatus(PerformanceStatus.BROUILLON) : 0)
                .build();
    }

    public List<Map<String, Object>> employeesByDepartment() {
        boolean hrAdmin = current.hasAnyRole(RoleName.HR, RoleName.ADMIN);
        boolean manager = current.hasRole(RoleName.MANAGER);
        Employee me = current.currentEmployee();
        Set<Long> visibleEmployeeIds = visibleEmployeeIds(hrAdmin, manager, me);
        return departmentRepository.findAll().stream().map(dept -> {
            long count = employeeRepository.findAll().stream()
                    .filter(e -> visibleEmployeeIds.contains(e.getId()))
                    .filter(e -> e.getDepartment() != null && e.getDepartment().getId().equals(dept.getId()))
                    .count();
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("label", dept.getName());
            row.put("value", count);
            return row;
        }).toList();
    }

    public List<Map<String, Object>> leavesByMonth() {
        Set<Long> visibleEmployeeIds = visibleEmployeeIds(current.hasAnyRole(RoleName.HR, RoleName.ADMIN), current.hasRole(RoleName.MANAGER), current.currentEmployee());
        Map<Integer, Long> grouped = leaveRepository.findAll().stream()
                .filter(l -> visibleEmployeeIds.contains(l.getEmployee().getId()))
                .collect(Collectors.groupingBy(l -> l.getStartDate().getMonthValue(), TreeMap::new, Collectors.counting()));
        return grouped.entrySet().stream().map(entry -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("month", entry.getKey());
            item.put("count", entry.getValue());
            return item;
        }).toList();
    }

    public List<Map<String, Object>> attendanceSummary() {
        Set<Long> visibleEmployeeIds = visibleEmployeeIds(current.hasAnyRole(RoleName.HR, RoleName.ADMIN), current.hasRole(RoleName.MANAGER), current.currentEmployee());
        LocalDate fromDate = LocalDate.now().minusDays(14);
        Map<LocalDate, Long> grouped = attendanceRepository.findAll().stream()
                .filter(a -> visibleEmployeeIds.contains(a.getEmployee().getId()))
                .filter(a -> !a.getDate().isBefore(fromDate))
                .collect(Collectors.groupingBy(a -> a.getDate(), TreeMap::new, Collectors.counting()));
        return grouped.entrySet().stream().map(entry -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("date", entry.getKey().toString());
            item.put("count", entry.getValue());
            return item;
        }).toList();
    }

    private Set<Long> visibleEmployeeIds(boolean hrAdmin, boolean manager, Employee me) {
        if (hrAdmin) {
            return employeeRepository.findAll().stream().map(Employee::getId).collect(Collectors.toSet());
        }
        if (manager) {
            Set<Long> team = employeeRepository.findByManagerId(me.getId()).stream().map(Employee::getId).collect(Collectors.toSet());
            team.add(me.getId());
            return team;
        }
        return Set.of(me.getId());
    }
}
