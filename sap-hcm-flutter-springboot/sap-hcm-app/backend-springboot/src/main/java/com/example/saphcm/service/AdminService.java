package com.example.saphcm.service;

import com.example.saphcm.dto.UserDto;
import com.example.saphcm.entity.Role;
import com.example.saphcm.entity.User;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.RoleRepository;
import com.example.saphcm.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<UserDto> users() {
        return userRepository.findAll().stream().map(mapper::toUserDto).toList();
    }

    public UserDto create(UserDto dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "Email deja utilise");
        }
        User user = new User(dto.getEmail(), passwordEncoder.encode("password"));
        RoleName roleName = dto.getRoles() != null && !dto.getRoles().isEmpty() ? RoleName.valueOf(dto.getRoles().get(0)) : RoleName.EMPLOYEE;
        Role role = roleRepository.findByName(roleName).orElseThrow();
        user.setRoles(Set.of(role));
        return mapper.toUserDto(userRepository.save(user));
    }

    public UserDto update(Long id, UserDto dto) {
        User user = get(id);
        user.setEmail(dto.getEmail());
        user.setEnabled(dto.isEnabled());
        return mapper.toUserDto(userRepository.save(user));
    }

    public UserDto updateRole(Long id, RoleName roleName) {
        User user = get(id);
        Role role = roleRepository.findByName(roleName)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Role introuvable"));
        user.setRoles(Set.of(role));
        return mapper.toUserDto(userRepository.save(user));
    }

    public UserDto updateStatus(Long id, boolean enabled) {
        User user = get(id);
        user.setEnabled(enabled);
        return mapper.toUserDto(userRepository.save(user));
    }

    private User get(Long id) {
        return userRepository.findById(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));
    }
}
