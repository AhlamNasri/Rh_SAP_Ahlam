package com.example.saphcm.repository;

import com.example.saphcm.entity.PerformanceReview;
import com.example.saphcm.enums.PerformanceStatus;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PerformanceReviewRepository extends JpaRepository<PerformanceReview, Long> {

    List<PerformanceReview> findByEmployeeId(Long employeeId);
    List<PerformanceReview> findByManagerId(Long managerId);
    long countByStatus(PerformanceStatus status);
}
