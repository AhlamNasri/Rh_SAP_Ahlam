package com.example.saphcm.controller;

import com.example.saphcm.dto.TrainingDto;
import com.example.saphcm.service.TrainingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trainings")
@RequiredArgsConstructor
public class TrainingController {
    private final TrainingService trainingService;

    @GetMapping
    public List<TrainingDto> all() {
        return trainingService.trainings();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public TrainingDto create(@Valid @RequestBody TrainingDto dto) {
        return trainingService.create(dto);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public TrainingDto update(@PathVariable Long id, @Valid @RequestBody TrainingDto dto) {
        return trainingService.update(id, dto);
    }

    @PostMapping("/{id}/enroll")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public TrainingDto enroll(@PathVariable Long id, @RequestBody Map<String, Long> body) {
        return trainingService.enroll(id, body.get("employeeId"));
    }

    @GetMapping("/my")
    public List<TrainingDto> my() {
        return trainingService.myTrainings();
    }
}
