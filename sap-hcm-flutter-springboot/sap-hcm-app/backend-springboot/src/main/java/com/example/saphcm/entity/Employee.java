package com.example.saphcm.entity;

import com.example.saphcm.enums.ContractType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "employees")
@Getter
@Setter
@NoArgsConstructor
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 40)
    private String employeeNumber;

    @Column(nullable = false, length = 80)
    private String firstName;

    @Column(nullable = false, length = 80)
    private String lastName;

    @Column(nullable = false, length = 120)
    private String jobTitle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;

    @Column(nullable = false, unique = true, length = 120)
    private String email;

    @Column(length = 30)
    private String phone;

    @Column(length = 255)
    private String address;

    private LocalDate hireDate;

    @Enumerated(EnumType.STRING)
    private ContractType contractType = ContractType.CDI;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id")
    private Employee manager;

    private boolean active = true;

    @Column(length = 400)
    private String avatarUrl;

    @Column(precision = 12, scale = 2)
    private BigDecimal baseSalary = BigDecimal.ZERO;

    private Integer annualLeaveBalance = 24;

    public String getFullName() {
        return firstName + " " + lastName;
    }
}
