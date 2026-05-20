package com.example.saphcm.controller;

import com.example.saphcm.dto.AttendanceDto;
import com.example.saphcm.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
public class AttendanceController {
    private final AttendanceService attendanceService;

    @GetMapping
    public List<AttendanceDto> all() {
        return attendanceService.findAll();
    }

    @GetMapping("/my")
    public List<AttendanceDto> my() {
        return attendanceService.myAttendance();
    }

    @PostMapping("/check-in")
    public AttendanceDto checkIn() {
        return attendanceService.checkIn();
    }

    @PostMapping("/check-out")
    public AttendanceDto checkOut() {
        return attendanceService.checkOut();
    }

    @GetMapping("/today")
    public Map<String, Object> today() {
        return attendanceService.today();
    }
}
