package com.example.saphcm.mapper;

import com.example.saphcm.dto.*;
import com.example.saphcm.entity.*;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DtoMapper {
    public EmployeeDto toEmployeeDto(Employee e) {
        if (e == null) return null;
        return EmployeeDto.builder()
                .id(e.getId())
                .employeeNumber(e.getEmployeeNumber())
                .firstName(e.getFirstName())
                .lastName(e.getLastName())
                .fullName(e.getFullName())
                .jobTitle(e.getJobTitle())
                .departmentId(e.getDepartment() != null ? e.getDepartment().getId() : null)
                .departmentName(e.getDepartment() != null ? e.getDepartment().getName() : null)
                .email(e.getEmail())
                .phone(e.getPhone())
                .address(e.getAddress())
                .hireDate(e.getHireDate())
                .contractType(e.getContractType())
                .managerId(e.getManager() != null ? e.getManager().getId() : null)
                .managerName(e.getManager() != null ? e.getManager().getFullName() : null)
                .active(e.isActive())
                .avatarUrl(e.getAvatarUrl())
                .baseSalary(e.getBaseSalary())
                .annualLeaveBalance(e.getAnnualLeaveBalance())
                .build();
    }

    public UserDto toUserDto(User user) {
        Employee e = user.getEmployee();
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .roles(user.getRoles().stream().map(r -> r.getName().name()).sorted().toList())
                .enabled(user.isEnabled())
                .createdAt(user.getCreatedAt())
                .employeeId(e != null ? e.getId() : null)
                .employeeName(e != null ? e.getFullName() : null)
                .department(e != null && e.getDepartment() != null ? e.getDepartment().getName() : null)
                .build();
    }

    public LeaveRequestDto toLeaveDto(LeaveRequest l) {
        return LeaveRequestDto.builder()
                .id(l.getId())
                .employeeId(l.getEmployee().getId())
                .employeeName(l.getEmployee().getFullName())
                .departmentName(l.getEmployee().getDepartment() != null ? l.getEmployee().getDepartment().getName() : null)
                .type(l.getType())
                .startDate(l.getStartDate())
                .endDate(l.getEndDate())
                .days(l.getDays())
                .reason(l.getReason())
                .status(l.getStatus())
                .approvedById(l.getApprovedBy() != null ? l.getApprovedBy().getId() : null)
                .approvedByName(l.getApprovedBy() != null ? l.getApprovedBy().getFullName() : null)
                .createdAt(l.getCreatedAt())
                .decisionAt(l.getDecisionAt())
                .build();
    }

    public AttendanceDto toAttendanceDto(Attendance a) {
        return AttendanceDto.builder()
                .id(a.getId())
                .employeeId(a.getEmployee().getId())
                .employeeName(a.getEmployee().getFullName())
                .departmentName(a.getEmployee().getDepartment() != null ? a.getEmployee().getDepartment().getName() : null)
                .date(a.getDate())
                .checkInTime(a.getCheckInTime())
                .checkOutTime(a.getCheckOutTime())
                .totalHours(a.getTotalHours())
                .status(a.getStatus())
                .build();
    }

    public PayrollDto toPayrollDto(Payroll p) {
        return PayrollDto.builder()
                .id(p.getId())
                .employeeId(p.getEmployee().getId())
                .employeeName(p.getEmployee().getFullName())
                .departmentName(p.getEmployee().getDepartment() != null ? p.getEmployee().getDepartment().getName() : null)
                .month(p.getMonth())
                .baseSalary(p.getBaseSalary())
                .bonuses(p.getBonuses())
                .overtime(p.getOvertime())
                .deductions(p.getDeductions())
                .charges(p.getCharges())
                .grossSalary(p.getGrossSalary())
                .netSalary(p.getNetSalary())
                .paymentDate(p.getPaymentDate())
                .status(p.getStatus())
                .build();
    }

    public JobOfferDto toJobOfferDto(JobOffer j) {
        return JobOfferDto.builder()
                .id(j.getId())
                .title(j.getTitle())
                .departmentId(j.getDepartment() != null ? j.getDepartment().getId() : null)
                .departmentName(j.getDepartment() != null ? j.getDepartment().getName() : null)
                .contractType(j.getContractType())
                .publicationDate(j.getPublicationDate())
                .status(j.getStatus())
                .description(j.getDescription())
                .build();
    }

    public CandidateDto toCandidateDto(Candidate c) {
        return CandidateDto.builder()
                .id(c.getId())
                .jobOfferId(c.getJobOffer() != null ? c.getJobOffer().getId() : null)
                .jobOfferTitle(c.getJobOffer() != null ? c.getJobOffer().getTitle() : null)
                .fullName(c.getFullName())
                .email(c.getEmail())
                .cvUrl(c.getCvUrl())
                .status(c.getStatus())
                .createdAt(c.getCreatedAt())
                .build();
    }

    public PerformanceReviewDto toPerformanceDto(PerformanceReview r) {
        return PerformanceReviewDto.builder()
                .id(r.getId())
                .employeeId(r.getEmployee().getId())
                .employeeName(r.getEmployee().getFullName())
                .managerId(r.getManager() != null ? r.getManager().getId() : null)
                .managerName(r.getManager() != null ? r.getManager().getFullName() : null)
                .period(r.getPeriod())
                .objective1(r.getObjective1())
                .objective2(r.getObjective2())
                .objective3(r.getObjective3())
                .score(r.getScore())
                .comment(r.getComment())
                .status(r.getStatus())
                .build();
    }

    public TrainingDto toTrainingDto(Training t, Integer progress, List<String> employees) {
        return TrainingDto.builder()
                .id(t.getId())
                .title(t.getTitle())
                .description(t.getDescription())
                .durationHours(t.getDurationHours())
                .trainer(t.getTrainer())
                .startDate(t.getStartDate())
                .endDate(t.getEndDate())
                .status(t.getStatus())
                .progressPercent(progress)
                .enrolledEmployees(employees)
                .build();
    }
}
