package com.example.saphcm.dto;

import com.example.saphcm.enums.CandidateStatus;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CandidateDto {
    private Long id;
    private Long jobOfferId;
    private String jobOfferTitle;
    @NotBlank
    private String fullName;
    @Email
    private String email;
    private String cvUrl;
    private CandidateStatus status;
    private LocalDateTime createdAt;
}
