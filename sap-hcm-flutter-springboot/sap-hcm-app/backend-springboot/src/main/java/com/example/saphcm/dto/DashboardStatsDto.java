package com.example.saphcm.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDto {
    private long totalEmployees;
    private long presentToday;
    private long pendingLeaves;
    private long approvedLeaves;
    private BigDecimal simulatedPayrollMass;
    private long recruitmentCandidates;
    private long activeTrainings;
    private long pendingReviews;
}
