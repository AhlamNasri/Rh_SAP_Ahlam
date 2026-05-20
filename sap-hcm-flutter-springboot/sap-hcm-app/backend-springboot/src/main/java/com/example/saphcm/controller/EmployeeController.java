package com.example.saphcm.controller;

import com.example.saphcm.dto.EmployeeDto;
import com.example.saphcm.dto.MessageResponse;
import com.example.saphcm.service.EmployeeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employees")
@RequiredArgsConstructor
public class EmployeeController {
    private final EmployeeService employeeService;

    @GetMapping
    public List<EmployeeDto> all() {
        return employeeService.findAll();
    }

    @GetMapping("/me")
    public EmployeeDto me() {
        return employeeService.me();
    }

    @GetMapping("/{id}")
    public EmployeeDto get(@PathVariable Long id) {
        return employeeService.getById(id);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public EmployeeDto create(@Valid @RequestBody EmployeeDto dto) {
        return employeeService.create(dto);
    }

    @PutMapping("/{id}")
    public EmployeeDto update(@PathVariable Long id, @Valid @RequestBody EmployeeDto dto) {
        return employeeService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public MessageResponse delete(@PathVariable Long id) {
        employeeService.delete(id);
        return new MessageResponse("Employe supprime");
    }
}
