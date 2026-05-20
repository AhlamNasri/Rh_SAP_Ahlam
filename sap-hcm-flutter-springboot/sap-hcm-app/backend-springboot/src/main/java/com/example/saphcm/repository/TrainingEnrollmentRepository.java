package com.example.saphcm.repository;

import com.example.saphcm.entity.TrainingEnrollment;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainingEnrollmentRepository extends JpaRepository<TrainingEnrollment, Long> {

    List<TrainingEnrollment> findByEmployeeId(Long employeeId);
    List<TrainingEnrollment> findByTrainingId(Long trainingId);
    Optional<TrainingEnrollment> findByTrainingIdAndEmployeeId(Long trainingId, Long employeeId);
}
