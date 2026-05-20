package com.example.saphcm.service;

import com.example.saphcm.dto.EmployeeDto;
import com.example.saphcm.entity.Department;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.DepartmentRepository;
import com.example.saphcm.repository.EmployeeRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class EmployeeService {
    private final EmployeeRepository employeeRepository;
    private final DepartmentRepository departmentRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<EmployeeDto> findAll() {
        if (current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            return employeeRepository.findAll().stream().map(mapper::toEmployeeDto).toList();
        }
        Employee me = current.currentEmployee();
        if (current.hasRole(RoleName.MANAGER)) {
            return employeeRepository.findByManagerId(me.getId()).stream().map(mapper::toEmployeeDto).toList();
        }
        return List.of(mapper.toEmployeeDto(me));
    }

    @Transactional(readOnly = true)
    public EmployeeDto getById(Long id) {
        Employee employee = getEmployee(id);
        ensureCanView(employee);
        return mapper.toEmployeeDto(employee);
    }

    @Transactional(readOnly = true)
    public EmployeeDto me() {
        return mapper.toEmployeeDto(current.currentEmployee());
    }

    public EmployeeDto create(EmployeeDto dto) {
        ensureHrAdmin();
        Employee employee = new Employee();
        fillEditableFields(employee, dto, true);
        return mapper.toEmployeeDto(employeeRepository.save(employee));
    }

    public EmployeeDto update(Long id, EmployeeDto dto) {
        Employee employee = getEmployee(id);
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            Employee me = current.currentEmployee();
            if (!employee.getId().equals(me.getId())) {
                throw new ApiException(HttpStatus.FORBIDDEN, "Modification non autorisee");
            }
            employee.setPhone(dto.getPhone());
            employee.setAddress(dto.getAddress());
            employee.setAvatarUrl(dto.getAvatarUrl());
            return mapper.toEmployeeDto(employeeRepository.save(employee));
        }
        fillEditableFields(employee, dto, false);
        return mapper.toEmployeeDto(employeeRepository.save(employee));
    }

    public void delete(Long id) {
        ensureHrAdmin();
        employeeRepository.delete(getEmployee(id));
    }

    private Employee getEmployee(Long id) {
        return employeeRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Employe introuvable"));
    }

    private void fillEditableFields(Employee employee, EmployeeDto dto, boolean creating) {
        if (creating) {
            employee.setEmployeeNumber(dto.getEmployeeNumber());
            employee.setEmail(dto.getEmail());
        }
        employee.setFirstName(dto.getFirstName());
        employee.setLastName(dto.getLastName());
        employee.setJobTitle(dto.getJobTitle());
        employee.setPhone(dto.getPhone());
        employee.setAddress(dto.getAddress());
        employee.setHireDate(dto.getHireDate());
        employee.setContractType(dto.getContractType());
        employee.setActive(dto.isActive());
        employee.setAvatarUrl(dto.getAvatarUrl());
        employee.setBaseSalary(dto.getBaseSalary());
        employee.setAnnualLeaveBalance(dto.getAnnualLeaveBalance() != null ? dto.getAnnualLeaveBalance() : 24);
        if (dto.getDepartmentId() != null) {
            Department department = departmentRepository.findById(dto.getDepartmentId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Departement introuvable"));
            employee.setDepartment(department);
        }
        if (dto.getManagerId() != null) {
            employee.setManager(getEmployee(dto.getManagerId()));
        }
    }

    private void ensureCanView(Employee target) {
        if (current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) return;
        Employee me = current.currentEmployee();
        if (target.getId().equals(me.getId())) return;
        if (current.hasRole(RoleName.MANAGER) && target.getManager() != null && target.getManager().getId().equals(me.getId())) return;
        throw new ApiException(HttpStatus.FORBIDDEN, "Acces employe non autorise");
    }

    private void ensureHrAdmin() {
        if (!current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Action reservee RH/Admin");
        }
    }
}
