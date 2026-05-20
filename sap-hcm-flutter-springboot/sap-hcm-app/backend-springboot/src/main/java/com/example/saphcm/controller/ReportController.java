package com.example.saphcm.controller;

import com.example.saphcm.dto.ReportDto;
import com.example.saphcm.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('HR','ADMIN')")
public class ReportController {
    private final ReportService reportService;

    @GetMapping("/leaves")
    public ReportDto leaves() {
        return reportService.leaves();
    }

    @GetMapping("/attendance")
    public ReportDto attendance() {
        return reportService.attendance();
    }

    @GetMapping("/payroll")
    public ReportDto payroll() {
        return reportService.payroll();
    }

    @GetMapping("/trainings")
    public ReportDto trainings() {
        return reportService.trainings();
    }

    @GetMapping("/performance")
    public ReportDto performance() {
        return reportService.performance();
    }
}
