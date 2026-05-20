package com.example.saphcm.controller;

import com.example.saphcm.dto.PayrollDto;
import com.example.saphcm.service.PayrollService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/payroll")
@RequiredArgsConstructor
public class PayrollController {
    private final PayrollService payrollService;

    @GetMapping
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public List<PayrollDto> all() {
        return payrollService.findAll();
    }

    @GetMapping("/my")
    public List<PayrollDto> my() {
        return payrollService.myPayrolls();
    }

    @GetMapping("/{id}")
    public PayrollDto get(@PathVariable Long id) {
        return payrollService.getById(id);
    }

    @GetMapping("/{id}/download")
    public ResponseEntity<byte[]> download(@PathVariable Long id) {
        byte[] document = payrollService.generatePayslipPdf(id);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"fiche-paie-" + id + ".pdf\"")
                .body(document);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('HR','ADMIN')")
    public PayrollDto create(@Valid @RequestBody PayrollDto dto) {
        return payrollService.create(dto);
    }
}
