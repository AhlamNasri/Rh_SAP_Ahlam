package com.example.saphcm.service.sap;

import com.example.saphcm.dto.AttendanceDto;
import java.util.List;

public interface SapAttendanceService {
    List<AttendanceDto> fetchAttendance();
}
