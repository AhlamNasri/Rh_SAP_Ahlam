package com.example.saphcm.service.sap;

import com.example.saphcm.dto.PayrollDto;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.PayrollRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockSapPayrollService implements SapPayrollService {
    private final PayrollRepository payrollRepository;
    private final DtoMapper mapper;

    @Override
    public List<PayrollDto> fetchPayrolls() {
        return payrollRepository.findAll().stream().map(mapper::toPayrollDto).toList();
    }
}
