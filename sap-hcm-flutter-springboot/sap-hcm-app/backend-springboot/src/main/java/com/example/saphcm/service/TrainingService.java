package com.example.saphcm.service;

import com.example.saphcm.dto.TrainingDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.Training;
import com.example.saphcm.entity.TrainingEnrollment;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.enums.TrainingStatus;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.EmployeeRepository;
import com.example.saphcm.repository.TrainingEnrollmentRepository;
import com.example.saphcm.repository.TrainingRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class TrainingService {
    private final TrainingRepository trainingRepository;
    private final TrainingEnrollmentRepository enrollmentRepository;
    private final EmployeeRepository employeeRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<TrainingDto> trainings() {
        return trainingRepository.findAll().stream().map(t -> mapper.toTrainingDto(t, null, employeeNames(t))).toList();
    }

    @Transactional(readOnly = true)
    public List<TrainingDto> myTrainings() {
        Employee me = current.currentEmployee();
        return enrollmentRepository.findByEmployeeId(me.getId()).stream()
                .map(enrollment -> mapper.toTrainingDto(enrollment.getTraining(), enrollment.getProgressPercent(), employeeNames(enrollment.getTraining())))
                .toList();
    }

    public TrainingDto create(TrainingDto dto) {
        ensureHrAdmin();
        Training training = new Training();
        fill(training, dto);
        return mapper.toTrainingDto(trainingRepository.save(training), null, List.of());
    }

    public TrainingDto update(Long id, TrainingDto dto) {
        ensureHrAdmin();
        Training training = get(id);
        fill(training, dto);
        return mapper.toTrainingDto(trainingRepository.save(training), null, employeeNames(training));
    }

    public TrainingDto enroll(Long trainingId, Long employeeId) {
        ensureHrAdmin();
        Training training = get(trainingId);
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Employe introuvable"));
        TrainingEnrollment enrollment = enrollmentRepository.findByTrainingIdAndEmployeeId(trainingId, employeeId)
                .orElseGet(TrainingEnrollment::new);
        enrollment.setTraining(training);
        enrollment.setEmployee(employee);
        if (enrollment.getProgressPercent() == null) enrollment.setProgressPercent(0);
        enrollmentRepository.save(enrollment);
        return mapper.toTrainingDto(training, null, employeeNames(training));
    }

    private void fill(Training training, TrainingDto dto) {
        training.setTitle(dto.getTitle());
        training.setDescription(dto.getDescription());
        training.setDurationHours(dto.getDurationHours());
        training.setTrainer(dto.getTrainer());
        training.setStartDate(dto.getStartDate());
        training.setEndDate(dto.getEndDate());
        training.setStatus(dto.getStatus() != null ? dto.getStatus() : TrainingStatus.PLANIFIEE);
    }

    private Training get(Long id) {
        return trainingRepository.findById(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Formation introuvable"));
    }

    private List<String> employeeNames(Training training) {
        return enrollmentRepository.findByTrainingId(training.getId()).stream()
                .map(e -> e.getEmployee().getFullName()).toList();
    }

    private void ensureHrAdmin() {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Action formation reservee RH/Admin");
        }
    }
}
