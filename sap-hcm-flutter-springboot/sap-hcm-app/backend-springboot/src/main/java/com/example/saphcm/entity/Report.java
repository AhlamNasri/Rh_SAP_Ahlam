package com.example.saphcm.entity;

import com.example.saphcm.enums.ReportType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "reports")
@Getter
@Setter
@NoArgsConstructor
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private ReportType type;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(length = 2000)
    private String payloadSummary;

    private LocalDateTime generatedAt = LocalDateTime.now();
}
