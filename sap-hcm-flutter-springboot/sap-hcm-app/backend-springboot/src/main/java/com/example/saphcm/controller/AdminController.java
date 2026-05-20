package com.example.saphcm.controller;

import com.example.saphcm.dto.UserDto;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('HR','ADMIN')")
public class AdminController {
    private final AdminService adminService;

    @GetMapping
    public List<UserDto> users() {
        return adminService.users();
    }

    @PostMapping
    public UserDto create(@Valid @RequestBody UserDto dto) {
        return adminService.create(dto);
    }

    @PutMapping("/{id}")
    public UserDto update(@PathVariable Long id, @Valid @RequestBody UserDto dto) {
        return adminService.update(id, dto);
    }

    @PutMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public UserDto updateRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return adminService.updateRole(id, RoleName.valueOf(body.get("role")));
    }

    @PutMapping("/{id}/status")
    public UserDto updateStatus(@PathVariable Long id, @RequestBody Map<String, Boolean> body) {
        return adminService.updateStatus(id, Boolean.TRUE.equals(body.get("enabled")));
    }
}
