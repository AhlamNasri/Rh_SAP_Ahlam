package com.example.saphcm.dto;

import com.example.saphcm.enums.ContractType;
import com.example.saphcm.enums.JobOfferStatus;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JobOfferDto {
    private Long id;
    @NotBlank
    private String title;
    private Long departmentId;
    private String departmentName;
    private ContractType contractType;
    private LocalDate publicationDate;
    private JobOfferStatus status;
    private String description;
}
