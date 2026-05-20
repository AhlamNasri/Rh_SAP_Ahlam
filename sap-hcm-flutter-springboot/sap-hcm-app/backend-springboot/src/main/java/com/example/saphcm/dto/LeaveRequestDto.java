package com.example.saphcm.dto;

import com.example.saphcm.enums.LeaveStatus;
import com.example.saphcm.enums.LeaveType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaveRequestDto {
    private Long id;
    private Long employeeId;
    private String employeeName;
    private String departmentName;
    private LeaveType type;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer days;
    private String reason;
    private LeaveStatus status;
    private Long approvedById;
    private String approvedByName;
    private LocalDateTime createdAt;
    private LocalDateTime decisionAt;
}
