package com.example.saphcm.service;

import com.example.saphcm.dto.CandidateDto;
import com.example.saphcm.dto.JobOfferDto;
import com.example.saphcm.entity.Candidate;
import com.example.saphcm.entity.Department;
import com.example.saphcm.entity.JobOffer;
import com.example.saphcm.enums.CandidateStatus;
import com.example.saphcm.enums.JobOfferStatus;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.CandidateRepository;
import com.example.saphcm.repository.DepartmentRepository;
import com.example.saphcm.repository.JobOfferRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class RecruitmentService {
    private final JobOfferRepository jobRepository;
    private final CandidateRepository candidateRepository;
    private final DepartmentRepository departmentRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<JobOfferDto> jobs() {
        return jobRepository.findAll().stream().map(mapper::toJobOfferDto).toList();
    }

    public JobOfferDto createJob(JobOfferDto dto) {
        ensureHrAdmin();
        JobOffer job = new JobOffer();
        fillJob(job, dto);
        return mapper.toJobOfferDto(jobRepository.save(job));
    }

    public JobOfferDto updateJob(Long id, JobOfferDto dto) {
        ensureHrAdmin();
        JobOffer job = jobRepository.findById(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Offre introuvable"));
        fillJob(job, dto);
        return mapper.toJobOfferDto(jobRepository.save(job));
    }

    public void deleteJob(Long id) {
        ensureHrAdmin();
        jobRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<CandidateDto> candidates() {
        return candidateRepository.findAll().stream().map(mapper::toCandidateDto).toList();
    }

    public CandidateDto createCandidate(CandidateDto dto) {
        Candidate candidate = new Candidate();
        candidate.setFullName(dto.getFullName());
        candidate.setEmail(dto.getEmail());
        candidate.setCvUrl(dto.getCvUrl());
        candidate.setStatus(dto.getStatus() != null ? dto.getStatus() : CandidateStatus.RECUE);
        if (dto.getJobOfferId() != null) {
            candidate.setJobOffer(jobRepository.findById(dto.getJobOfferId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Offre introuvable")));
        }
        return mapper.toCandidateDto(candidateRepository.save(candidate));
    }

    public CandidateDto updateCandidateStatus(Long id, CandidateStatus status) {
        ensureHrAdmin();
        Candidate candidate = candidateRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Candidat introuvable"));
        candidate.setStatus(status);
        return mapper.toCandidateDto(candidateRepository.save(candidate));
    }

    private void fillJob(JobOffer job, JobOfferDto dto) {
        job.setTitle(dto.getTitle());
        job.setContractType(dto.getContractType());
        job.setPublicationDate(dto.getPublicationDate() != null ? dto.getPublicationDate() : LocalDate.now());
        job.setStatus(dto.getStatus() != null ? dto.getStatus() : JobOfferStatus.OUVERTE);
        job.setDescription(dto.getDescription());
        if (dto.getDepartmentId() != null) {
            Department department = departmentRepository.findById(dto.getDepartmentId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Departement introuvable"));
            job.setDepartment(department);
        }
    }

    private void ensureHrAdmin() {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Action recrutement reservee RH/Admin");
        }
    }
}
