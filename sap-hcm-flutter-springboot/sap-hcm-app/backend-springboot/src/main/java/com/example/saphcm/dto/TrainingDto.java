package com.example.saphcm.dto;

import com.example.saphcm.enums.TrainingStatus;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrainingDto {
    private Long id;
    @NotBlank
    private String title;
    private String description;
    private Integer durationHours;
    private String trainer;
    private LocalDate startDate;
    private LocalDate endDate;
    private TrainingStatus status;
    private Integer progressPercent;
    private List<String> enrolledEmployees;
}
