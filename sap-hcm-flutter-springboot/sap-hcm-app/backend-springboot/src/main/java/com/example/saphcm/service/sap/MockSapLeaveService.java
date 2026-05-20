package com.example.saphcm.service.sap;

import com.example.saphcm.dto.LeaveRequestDto;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.LeaveRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockSapLeaveService implements SapLeaveService {
    private final LeaveRequestRepository leaveRequestRepository;
    private final DtoMapper mapper;

    @Override
    public List<LeaveRequestDto> fetchLeaves() {
        return leaveRequestRepository.findAll().stream().map(mapper::toLeaveDto).toList();
    }
}
