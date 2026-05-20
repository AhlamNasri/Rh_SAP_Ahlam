package com.example.saphcm.repository;

import com.example.saphcm.entity.Training;
import com.example.saphcm.enums.TrainingStatus;
import java.util.Collection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainingRepository extends JpaRepository<Training, Long> {

    long countByStatusIn(Collection<TrainingStatus> statuses);
}
