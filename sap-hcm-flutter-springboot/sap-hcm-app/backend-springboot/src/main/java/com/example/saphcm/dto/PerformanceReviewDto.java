package com.example.saphcm.dto;

import com.example.saphcm.enums.PerformanceStatus;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerformanceReviewDto {
    private Long id;
    private Long employeeId;
    private String employeeName;
    private Long managerId;
    private String managerName;
    private String period;
    private String objective1;
    private String objective2;
    private String objective3;
    @Min(1)
    @Max(5)
    private Integer score;
    private String comment;
    private PerformanceStatus status;
}
