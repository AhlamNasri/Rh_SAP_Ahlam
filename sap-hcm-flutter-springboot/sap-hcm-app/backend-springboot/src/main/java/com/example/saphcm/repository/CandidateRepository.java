package com.example.saphcm.repository;

import com.example.saphcm.entity.Candidate;
import com.example.saphcm.enums.CandidateStatus;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CandidateRepository extends JpaRepository<Candidate, Long> {

    List<Candidate> findByJobOfferId(Long jobOfferId);
    long countByStatus(CandidateStatus status);
}
