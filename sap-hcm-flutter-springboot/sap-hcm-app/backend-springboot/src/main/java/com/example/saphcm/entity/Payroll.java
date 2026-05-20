package com.example.saphcm.entity;

import com.example.saphcm.enums.PayrollStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "payroll")
@Getter
@Setter
@NoArgsConstructor
public class Payroll {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "employee_id")
    private Employee employee;

    @Column(name = "payroll_month", nullable = false, length = 7)
    private String month;

    @Column(precision = 12, scale = 2)
    private BigDecimal baseSalary = BigDecimal.ZERO;

    @Column(precision = 12, scale = 2)
    private BigDecimal bonuses = BigDecimal.ZERO;

    @Column(precision = 12, scale = 2)
    private BigDecimal overtime = BigDecimal.ZERO;

    @Column(precision = 12, scale = 2)
    private BigDecimal deductions = BigDecimal.ZERO;

    @Column(precision = 12, scale = 2)
    private BigDecimal charges = BigDecimal.ZERO;

    @Column(precision = 12, scale = 2)
    private BigDecimal grossSalary = BigDecimal.ZERO;

    @Column(precision = 12, scale = 2)
    private BigDecimal netSalary = BigDecimal.ZERO;

    private LocalDate paymentDate;

    @Enumerated(EnumType.STRING)
    private PayrollStatus status = PayrollStatus.EN_ATTENTE;
}
