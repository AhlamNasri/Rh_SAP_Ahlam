package com.example.saphcm.controller;

import com.example.saphcm.dto.DashboardStatsDto;
import com.example.saphcm.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    private final DashboardService dashboardService;

    @GetMapping("/stats")
    public DashboardStatsDto stats() {
        return dashboardService.stats();
    }

    @GetMapping("/employees-by-department")
    public List<Map<String, Object>> employeesByDepartment() {
        return dashboardService.employeesByDepartment();
    }

    @GetMapping("/leaves-by-month")
    public List<Map<String, Object>> leavesByMonth() {
        return dashboardService.leavesByMonth();
    }

    @GetMapping("/attendance-summary")
    public List<Map<String, Object>> attendanceSummary() {
        return dashboardService.attendanceSummary();
    }
}
