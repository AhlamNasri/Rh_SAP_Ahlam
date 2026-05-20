package com.example.saphcm.dto;

import com.example.saphcm.enums.LeaveType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class LeaveCreateRequest {
    @NotNull
    private LeaveType type;
    @NotNull
    private LocalDate startDate;
    @NotNull
    private LocalDate endDate;
    @Size(max = 800)
    private String reason;
}
