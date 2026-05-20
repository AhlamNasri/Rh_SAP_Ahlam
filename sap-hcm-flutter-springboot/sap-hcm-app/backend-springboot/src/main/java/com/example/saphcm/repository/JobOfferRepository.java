package com.example.saphcm.repository;

import com.example.saphcm.entity.JobOffer;
import com.example.saphcm.enums.JobOfferStatus;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JobOfferRepository extends JpaRepository<JobOffer, Long> {

    List<JobOffer> findByStatus(JobOfferStatus status);
}
