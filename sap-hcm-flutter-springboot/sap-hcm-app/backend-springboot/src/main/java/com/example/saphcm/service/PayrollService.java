package com.example.saphcm.service;

import com.example.saphcm.dto.PayrollDto;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.entity.Payroll;
import com.example.saphcm.enums.PayrollStatus;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.EmployeeRepository;
import com.example.saphcm.repository.PayrollRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class PayrollService {
    private final PayrollRepository payrollRepository;
    private final EmployeeRepository employeeRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<PayrollDto> findAll() {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "La paie globale est reservee a RH/Admin");
        }
        return payrollRepository.findAll().stream().map(mapper::toPayrollDto).toList();
    }

    @Transactional(readOnly = true)
    public List<PayrollDto> myPayrolls() {
        Employee me = current.currentEmployee();
        return payrollRepository.findByEmployeeIdOrderByMonthDesc(me.getId()).stream().map(mapper::toPayrollDto).toList();
    }

    @Transactional(readOnly = true)
    public PayrollDto getById(Long id) {
        Payroll payroll = get(id);
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            Employee me = current.currentEmployee();
            if (!payroll.getEmployee().getId().equals(me.getId())) {
                throw new ApiException(HttpStatus.FORBIDDEN, "Acces fiche de paie non autorise");
            }
        }
        return mapper.toPayrollDto(payroll);
    }

    public PayrollDto create(PayrollDto dto) {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Creation paie reservee RH/Admin");
        }
        Employee employee = employeeRepository.findById(dto.getEmployeeId())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Employe introuvable"));
        Payroll payroll = new Payroll();
        payroll.setEmployee(employee);
        payroll.setMonth(dto.getMonth());
        payroll.setBaseSalary(nvl(dto.getBaseSalary()));
        payroll.setBonuses(nvl(dto.getBonuses()));
        payroll.setOvertime(nvl(dto.getOvertime()));
        payroll.setDeductions(nvl(dto.getDeductions()));
        payroll.setCharges(nvl(dto.getCharges()));
        payroll.setGrossSalary(payroll.getBaseSalary().add(payroll.getBonuses()).add(payroll.getOvertime()));
        payroll.setNetSalary(payroll.getGrossSalary().subtract(payroll.getDeductions()).subtract(payroll.getCharges()));
        payroll.setPaymentDate(dto.getPaymentDate());
        payroll.setStatus(dto.getStatus() != null ? dto.getStatus() : PayrollStatus.EN_ATTENTE);
        return mapper.toPayrollDto(payrollRepository.save(payroll));
    }

    private Payroll get(Long id) {
        return payrollRepository.findById(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Fiche de paie introuvable"));
    }

    private BigDecimal nvl(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}
