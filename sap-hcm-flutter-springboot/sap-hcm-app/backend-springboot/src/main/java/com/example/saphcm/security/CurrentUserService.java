package com.example.saphcm.security;

import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.User;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CurrentUserService {
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public User currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Utilisateur non authentifie");
        }
        return userRepository.findByEmail(auth.getName())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Utilisateur non authentifie"));
    }

    @Transactional(readOnly = true)
    public Employee currentEmployee() {
        Employee employee = currentUser().getEmployee();
        if (employee == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Compte utilisateur sans employe lie");
        }
        return employee;
    }

    public boolean hasRole(RoleName role) {
        return currentUser().getRoles().stream().anyMatch(r -> r.getName() == role);
    }

    public boolean hasAnyRole(RoleName... roles) {
        for (RoleName role : roles) {
            if (hasRole(role)) return true;
        }
        return false;
    }
}
