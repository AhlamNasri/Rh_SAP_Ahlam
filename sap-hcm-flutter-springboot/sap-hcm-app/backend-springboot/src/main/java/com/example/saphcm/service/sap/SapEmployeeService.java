package com.example.saphcm.service.sap;

import com.example.saphcm.dto.EmployeeDto;
import java.util.List;

public interface SapEmployeeService {
    List<EmployeeDto> fetchEmployees();
}
