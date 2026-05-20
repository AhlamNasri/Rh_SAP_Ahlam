package com.example.saphcm.service;

import com.example.saphcm.dto.PerformanceReviewDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.PerformanceReview;
import com.example.saphcm.enums.PerformanceStatus;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.EmployeeRepository;
import com.example.saphcm.repository.PerformanceReviewRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class PerformanceService {
    private final PerformanceReviewRepository performanceRepository;
    private final EmployeeRepository employeeRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<PerformanceReviewDto> findAll() {
        if (current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            return performanceRepository.findAll().stream().map(mapper::toPerformanceDto).toList();
        }
        Employee me = current.currentEmployee();
        if (current.hasRole(RoleName.MANAGER)) {
            return performanceRepository.findByManagerId(me.getId()).stream().map(mapper::toPerformanceDto).toList();
        }
        return myReviews();
    }

    @Transactional(readOnly = true)
    public List<PerformanceReviewDto> myReviews() {
        return performanceRepository.findByEmployeeId(current.currentEmployee().getId()).stream().map(mapper::toPerformanceDto).toList();
    }

    public PerformanceReviewDto create(PerformanceReviewDto dto) {
        if (!current.hasAnyRole(RoleName.MANAGER, RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Evaluation reservee Manager/RH/Admin");
        }
        Employee employee = employeeRepository.findById(dto.getEmployeeId())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Employe introuvable"));
        if (current.hasRole(RoleName.MANAGER) && !current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            Employee manager = current.currentEmployee();
            if (employee.getManager() == null || !employee.getManager().getId().equals(manager.getId())) {
                throw new ApiException(HttpStatus.FORBIDDEN, "Un manager evalue uniquement son equipe");
            }
        }
        PerformanceReview review = new PerformanceReview();
        fill(review, dto);
        review.setEmployee(employee);
        review.setManager(current.currentEmployee());
        return mapper.toPerformanceDto(performanceRepository.save(review));
    }

    public PerformanceReviewDto update(Long id, PerformanceReviewDto dto) {
        PerformanceReview review = performanceRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Evaluation introuvable"));
        if (!current.hasAnyRole(RoleName.MANAGER, RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Modification evaluation non autorisee");
        }
        fill(review, dto);
        return mapper.toPerformanceDto(performanceRepository.save(review));
    }

    private void fill(PerformanceReview review, PerformanceReviewDto dto) {
        review.setPeriod(dto.getPeriod());
        review.setObjective1(dto.getObjective1());
        review.setObjective2(dto.getObjective2());
        review.setObjective3(dto.getObjective3());
        review.setScore(dto.getScore());
        review.setComment(dto.getComment());
        review.setStatus(dto.getStatus() != null ? dto.getStatus() : PerformanceStatus.BROUILLON);
    }
}
