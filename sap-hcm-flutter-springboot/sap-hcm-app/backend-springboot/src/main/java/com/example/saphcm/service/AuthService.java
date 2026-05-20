package com.example.saphcm.service;

import com.example.saphcm.dto.AuthResponse;
import com.example.saphcm.dto.LoginRequest;
import com.example.saphcm.dto.RegisterRequest;
import com.example.saphcm.dto.UserDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.Role;
import com.example.saphcm.entity.User;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.RoleRepository;
import com.example.saphcm.repository.UserRepository;
import com.example.saphcm.security.CurrentUserService;
import com.example.saphcm.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final CurrentUserService currentUserService;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Identifiants invalides"));
        return buildResponse(user);
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "Email deja utilise");
        }
        Role role = roleRepository.findByName(request.getRole())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Role introuvable"));
        User user = new User(request.getEmail(), passwordEncoder.encode(request.getPassword()));
        user.setRoles(Set.of(role));
        userRepository.save(user);
        return buildResponse(user);
    }

    @Transactional(readOnly = true)
    public UserDto me() {
        return mapper.toUserDto(currentUserService.currentUser());
    }

    private AuthResponse buildResponse(User user) {
        List<String> roles = user.getRoles().stream().map(r -> r.getName().name()).sorted().toList();
        Employee employee = user.getEmployee();
        Map<String, Object> claims = new HashMap<>();
        claims.put("roles", roles);
        claims.put("employeeId", employee != null ? employee.getId() : null);
        String token = jwtService.generateToken(user, claims);
        return AuthResponse.builder()
                .token(token)
                .type("Bearer")
                .userId(user.getId())
                .employeeId(employee != null ? employee.getId() : null)
                .email(user.getEmail())
                .fullName(employee != null ? employee.getFullName() : user.getEmail())
                .roles(roles)
                .build();
    }
}
