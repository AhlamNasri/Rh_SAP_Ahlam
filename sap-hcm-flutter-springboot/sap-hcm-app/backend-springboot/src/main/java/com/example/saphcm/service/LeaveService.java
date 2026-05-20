package com.example.saphcm.service;

import com.example.saphcm.dto.LeaveCreateRequest;
import com.example.saphcm.dto.LeaveRequestDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.LeaveRequest;
import com.example.saphcm.enums.LeaveStatus;
import com.example.saphcm.enums.LeaveType;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.LeaveRequestRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class LeaveService {
    private final LeaveRequestRepository leaveRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<LeaveRequestDto> findAll() {
        if (current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            return leaveRepository.findAll().stream().map(mapper::toLeaveDto).toList();
        }
        Employee me = current.currentEmployee();
        if (current.hasRole(RoleName.MANAGER)) {
            return leaveRepository.findByEmployeeManagerIdOrderByCreatedAtDesc(me.getId()).stream().map(mapper::toLeaveDto).toList();
        }
        return myLeaves();
    }

    @Transactional(readOnly = true)
    public List<LeaveRequestDto> myLeaves() {
        return leaveRepository.findByEmployeeIdOrderByCreatedAtDesc(current.currentEmployee().getId())
                .stream().map(mapper::toLeaveDto).toList();
    }

    public LeaveRequestDto create(LeaveCreateRequest request) {
        Employee employee = current.currentEmployee();
        int days = calculateDays(request);
        if (request.getType() == LeaveType.CONGE_ANNUEL && days > remainingAnnualDays(employee, null)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Solde de conges annuel insuffisant");
        }
        LeaveRequest leave = new LeaveRequest();
        leave.setEmployee(employee);
        leave.setType(request.getType());
        leave.setStartDate(request.getStartDate());
        leave.setEndDate(request.getEndDate());
        leave.setDays(days);
        leave.setReason(request.getReason());
        leave.setStatus(LeaveStatus.EN_ATTENTE);
        return mapper.toLeaveDto(leaveRepository.save(leave));
    }

    public LeaveRequestDto approve(Long id) {
        LeaveRequest leave = get(id);
        ensureCanDecide(leave);
        if (leave.getType() == LeaveType.CONGE_ANNUEL && leave.getDays() > remainingAnnualDays(leave.getEmployee(), leave.getId())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Solde insuffisant au moment de l'approbation");
        }
        leave.setStatus(LeaveStatus.APPROUVE);
        leave.setApprovedBy(current.currentEmployee());
        leave.setDecisionAt(LocalDateTime.now());
        return mapper.toLeaveDto(leaveRepository.save(leave));
    }

    public LeaveRequestDto reject(Long id) {
        LeaveRequest leave = get(id);
        ensureCanDecide(leave);
        leave.setStatus(LeaveStatus.REFUSE);
        leave.setApprovedBy(current.currentEmployee());
        leave.setDecisionAt(LocalDateTime.now());
        return mapper.toLeaveDto(leaveRepository.save(leave));
    }

    public void delete(Long id) {
        LeaveRequest leave = get(id);
        Employee me = current.currentEmployee();
        boolean ownerPending = leave.getEmployee().getId().equals(me.getId()) && leave.getStatus() == LeaveStatus.EN_ATTENTE;
        if (!ownerPending && !current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Suppression non autorisee");
        }
        leaveRepository.delete(leave);
    }

    private LeaveRequest get(Long id) {
        return leaveRepository.findById(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Demande de conge introuvable"));
    }

    private int calculateDays(LeaveCreateRequest request) {
        if (request.getEndDate().isBefore(request.getStartDate())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "La date de fin doit etre apres la date de debut");
        }
        return (int) ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate()) + 1;
    }

    private int remainingAnnualDays(Employee employee, Long excludeLeaveId) {
        int used = leaveRepository.findByEmployeeIdOrderByCreatedAtDesc(employee.getId()).stream()
                .filter(l -> excludeLeaveId == null || !l.getId().equals(excludeLeaveId))
                .filter(l -> l.getType() == LeaveType.CONGE_ANNUEL)
                .filter(l -> l.getStatus() == LeaveStatus.APPROUVE || l.getStatus() == LeaveStatus.EN_ATTENTE)
                .mapToInt(LeaveRequest::getDays)
                .sum();
        return Math.max(0, employee.getAnnualLeaveBalance() - used);
    }

    private void ensureCanDecide(LeaveRequest leave) {
        if (leave.getStatus() != LeaveStatus.EN_ATTENTE) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Cette demande a deja ete traitee");
        }
        if (current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) return;
        Employee me = current.currentEmployee();
        if (current.hasRole(RoleName.MANAGER)
                && leave.getEmployee().getManager() != null
                && leave.getEmployee().getManager().getId().equals(me.getId())) {
            return;
        }
        throw new ApiException(HttpStatus.FORBIDDEN, "Validation reservee au manager/RH/Admin");
    }
}
