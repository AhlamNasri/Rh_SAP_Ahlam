package com.example.saphcm.dto;

import com.example.saphcm.enums.ContractType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
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
public class EmployeeDto {
    private Long id;
    @NotBlank
    private String employeeNumber;
    @NotBlank
    private String firstName;
    @NotBlank
    private String lastName;
    private String fullName;
    private String jobTitle;
    private Long departmentId;
    private String departmentName;
    @Email
    private String email;
    private String phone;
    private String address;
    private LocalDate hireDate;
    private ContractType contractType;
    private Long managerId;
    private String managerName;
    private boolean active;
    private String avatarUrl;
    private BigDecimal baseSalary;
    private Integer annualLeaveBalance;
}
