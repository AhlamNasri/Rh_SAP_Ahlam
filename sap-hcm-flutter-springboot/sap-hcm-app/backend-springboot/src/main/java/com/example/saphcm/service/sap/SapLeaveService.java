package com.example.saphcm.service.sap;

import com.example.saphcm.dto.LeaveRequestDto;
import java.util.List;

public interface SapLeaveService {
    List<LeaveRequestDto> fetchLeaves();
}
