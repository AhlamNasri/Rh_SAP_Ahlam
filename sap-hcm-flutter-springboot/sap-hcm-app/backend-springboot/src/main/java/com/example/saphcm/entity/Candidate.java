package com.example.saphcm.entity;

import com.example.saphcm.enums.CandidateStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "candidates")
@Getter
@Setter
@NoArgsConstructor
public class Candidate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_offer_id")
    private JobOffer jobOffer;

    @Column(nullable = false, length = 120)
    private String fullName;

    @Column(nullable = false, length = 120)
    private String email;

    @Column(length = 400)
    private String cvUrl;

    @Enumerated(EnumType.STRING)
    private CandidateStatus status = CandidateStatus.RECUE;

    private LocalDateTime createdAt = LocalDateTime.now();
}
