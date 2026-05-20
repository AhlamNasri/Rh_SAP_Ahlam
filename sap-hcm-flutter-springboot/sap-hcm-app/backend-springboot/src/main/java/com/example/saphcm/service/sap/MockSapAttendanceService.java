package com.example.saphcm.service.sap;

import com.example.saphcm.dto.AttendanceDto;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.AttendanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockSapAttendanceService implements SapAttendanceService {
    private final AttendanceRepository attendanceRepository;
    private final DtoMapper mapper;

    @Override
    public List<AttendanceDto> fetchAttendance() {
        return attendanceRepository.findAll().stream().map(mapper::toAttendanceDto).toList();
    }
}
