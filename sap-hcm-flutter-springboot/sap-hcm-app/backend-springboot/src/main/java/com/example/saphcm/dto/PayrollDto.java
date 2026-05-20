package com.example.saphcm.dto;

import com.example.saphcm.enums.PayrollStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayrollDto {
    private Long id;
    private Long employeeId;
    private String employeeName;
    private String departmentName;
    private String month;
    private BigDecimal baseSalary;
    private BigDecimal bonuses;
    private BigDecimal overtime;
    private BigDecimal deductions;
    private BigDecimal charges;
    private BigDecimal grossSalary;
    private BigDecimal netSalary;
    private LocalDate paymentDate;
    private PayrollStatus status;
}
