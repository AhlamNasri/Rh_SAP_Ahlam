package com.example.saphcm.service.sap;

import com.example.saphcm.dto.PayrollDto;
import java.util.List;

public interface SapPayrollService {
    List<PayrollDto> fetchPayrolls();
}
