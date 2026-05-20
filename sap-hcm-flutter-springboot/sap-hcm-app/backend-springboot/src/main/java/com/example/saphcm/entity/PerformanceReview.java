package com.example.saphcm.entity;

import com.example.saphcm.enums.PerformanceStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "performance_reviews")
@Getter
@Setter
@NoArgsConstructor
public class PerformanceReview {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "employee_id")
    private Employee employee;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id")
    private Employee manager;

    @Column(nullable = false, length = 40)
    private String period;

    @Column(length = 500)
    private String objective1;
    @Column(length = 500)
    private String objective2;
    @Column(length = 500)
    private String objective3;

    private Integer score;

    @Column(length = 1200)
    private String comment;

    @Enumerated(EnumType.STRING)
    private PerformanceStatus status = PerformanceStatus.BROUILLON;
}
