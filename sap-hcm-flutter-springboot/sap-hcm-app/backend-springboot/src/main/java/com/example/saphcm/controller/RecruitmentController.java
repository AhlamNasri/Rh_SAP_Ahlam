package com.example.saphcm.controller;

import com.example.saphcm.dto.CandidateDto;
import com.example.saphcm.dto.JobOfferDto;
import com.example.saphcm.dto.MessageResponse;
import com.example.saphcm.enums.CandidateStatus;
import com.example.saphcm.service.RecruitmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class RecruitmentController {
    private final RecruitmentService recruitmentService;

    @GetMapping("/api/jobs")
    public List<JobOfferDto> jobs() {
        return recruitmentService.jobs();
    }

    @PostMapping("/api/jobs")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public JobOfferDto createJob(@Valid @RequestBody JobOfferDto dto) {
        return recruitmentService.createJob(dto);
    }

    @PutMapping("/api/jobs/{id}")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public JobOfferDto updateJob(@PathVariable Long id, @Valid @RequestBody JobOfferDto dto) {
        return recruitmentService.updateJob(id, dto);
    }

    @DeleteMapping("/api/jobs/{id}")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public MessageResponse deleteJob(@PathVariable Long id) {
        recruitmentService.deleteJob(id);
        return new MessageResponse("Offre supprimee");
    }

    @GetMapping("/api/candidates")
    public List<CandidateDto> candidates() {
        return recruitmentService.candidates();
    }

    @PostMapping("/api/candidates")
    public CandidateDto createCandidate(@Valid @RequestBody CandidateDto dto) {
        return recruitmentService.createCandidate(dto);
    }

    @PutMapping("/api/candidates/{id}/status")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public CandidateDto updateCandidateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return recruitmentService.updateCandidateStatus(id, CandidateStatus.valueOf(body.get("status")));
    }
}
