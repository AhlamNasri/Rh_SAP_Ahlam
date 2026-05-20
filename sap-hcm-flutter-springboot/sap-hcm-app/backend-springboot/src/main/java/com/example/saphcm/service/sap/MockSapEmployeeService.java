package com.example.saphcm.service.sap;

import com.example.saphcm.dto.EmployeeDto;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockSapEmployeeService implements SapEmployeeService {
    private final EmployeeRepository employeeRepository;
    private final DtoMapper mapper;

    @Override
    public List<EmployeeDto> fetchEmployees() {
        return employeeRepository.findAll().stream().map(mapper::toEmployeeDto).toList();
    }
}
