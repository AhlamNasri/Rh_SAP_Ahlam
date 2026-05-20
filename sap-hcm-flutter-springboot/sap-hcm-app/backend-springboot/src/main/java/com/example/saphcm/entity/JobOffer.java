package com.example.saphcm.entity;

import com.example.saphcm.enums.ContractType;
import com.example.saphcm.enums.JobOfferStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "job_offers")
@Getter
@Setter
@NoArgsConstructor
public class JobOffer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 160)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;

    @Enumerated(EnumType.STRING)
    private ContractType contractType = ContractType.CDI;

    private LocalDate publicationDate;

    @Enumerated(EnumType.STRING)
    private JobOfferStatus status = JobOfferStatus.OUVERTE;

    @Column(length = 1200)
    private String description;
}
