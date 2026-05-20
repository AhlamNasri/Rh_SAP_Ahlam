package com.example.saphcm.controller;

import com.example.saphcm.dto.PerformanceReviewDto;
import com.example.saphcm.service.PerformanceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/performance")
@RequiredArgsConstructor
public class PerformanceController {
    private final PerformanceService performanceService;

    @GetMapping
    public List<PerformanceReviewDto> all() {
        return performanceService.findAll();
    }

    @GetMapping("/my")
    public List<PerformanceReviewDto> my() {
        return performanceService.myReviews();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('MANAGER','HR','ADMIN')")
    public PerformanceReviewDto create(@Valid @RequestBody PerformanceReviewDto dto) {
        return performanceService.create(dto);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER','HR','ADMIN')")
    public PerformanceReviewDto update(@PathVariable Long id, @Valid @RequestBody PerformanceReviewDto dto) {
        return performanceService.update(id, dto);
    }
}
