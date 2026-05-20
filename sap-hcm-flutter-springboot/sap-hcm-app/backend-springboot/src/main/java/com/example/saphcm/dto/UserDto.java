package com.example.saphcm.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private Long id;
    private String email;
    private List<String> roles;
    private boolean enabled;
    private LocalDateTime createdAt;
    private Long employeeId;
    private String employeeName;
    private String department;
}
