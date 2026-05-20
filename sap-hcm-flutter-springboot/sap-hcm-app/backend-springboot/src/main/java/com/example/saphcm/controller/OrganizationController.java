package com.example.saphcm.controller;

import com.example.saphcm.service.OrganizationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/organization")
@RequiredArgsConstructor
public class OrganizationController {
    private final OrganizationService organizationService;

    @GetMapping("/tree")
    public Map<String, Object> tree() {
        return organizationService.tree();
    }
}
