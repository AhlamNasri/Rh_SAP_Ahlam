package com.example.saphcm.controller;

import com.example.saphcm.dto.AuthResponse;
import com.example.saphcm.dto.LoginRequest;
import com.example.saphcm.dto.RegisterRequest;
import com.example.saphcm.dto.UserDto;
import com.example.saphcm.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @GetMapping("/me")
    public UserDto me() {
        return authService.me();
    }
}
