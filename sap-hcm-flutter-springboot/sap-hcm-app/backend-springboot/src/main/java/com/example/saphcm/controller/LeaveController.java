package com.example.saphcm.controller;

import com.example.saphcm.dto.LeaveCreateRequest;
import com.example.saphcm.dto.LeaveRequestDto;
import com.example.saphcm.dto.MessageResponse;
import com.example.saphcm.service.LeaveService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/leaves")
@RequiredArgsConstructor
public class LeaveController {
    private final LeaveService leaveService;

    @GetMapping
    public List<LeaveRequestDto> all() {
        return leaveService.findAll();
    }

    @GetMapping("/my")
    public List<LeaveRequestDto> my() {
        return leaveService.myLeaves();
    }

    @PostMapping
    public LeaveRequestDto create(@Valid @RequestBody LeaveCreateRequest request) {
        return leaveService.create(request);
    }

    @PutMapping("/{id}/approve")
    @PreAuthorize("hasAnyRole('MANAGER','HR','ADMIN')")
    public LeaveRequestDto approve(@PathVariable Long id) {
        return leaveService.approve(id);
    }

    @PutMapping("/{id}/reject")
    @PreAuthorize("hasAnyRole('MANAGER','HR','ADMIN')")
    public LeaveRequestDto reject(@PathVariable Long id) {
        return leaveService.reject(id);
    }

    @DeleteMapping("/{id}")
    public MessageResponse delete(@PathVariable Long id) {
        leaveService.delete(id);
        return new MessageResponse("Demande supprimee");
    }
}
