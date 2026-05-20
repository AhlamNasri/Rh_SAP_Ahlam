package com.example.saphcm.service;

import com.example.saphcm.dto.AttendanceDto;
import com.example.saphcm.entity.Attendance;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.enums.AttendanceStatus;
import com.example.saphcm.enums.RoleName;
import com.example.saphcm.exception.ApiException;
import com.example.saphcm.mapper.DtoMapper;
import com.example.saphcm.repository.AttendanceRepository;
import com.example.saphcm.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class AttendanceService {
    private final AttendanceRepository attendanceRepository;
    private final CurrentUserService current;
    private final DtoMapper mapper;

    @Transactional(readOnly = true)
    public List<AttendanceDto> findAll() {
        if (current.hasAnyRole(RoleName.HR, RoleName.ADMIN)) {
            return attendanceRepository.findAll().stream().map(mapper::toAttendanceDto).toList();
        }
        Employee me = current.currentEmployee();
        if (current.hasRole(RoleName.MANAGER)) {
            return attendanceRepository.findByEmployeeManagerIdOrderByDateDesc(me.getId()).stream().map(mapper::toAttendanceDto).toList();
        }
        return myAttendance();
    }

    @Transactional(readOnly = true)
    public List<AttendanceDto> myAttendance() {
        return attendanceRepository.findByEmployeeIdOrderByDateDesc(current.currentEmployee().getId()).stream()
                .map(mapper::toAttendanceDto).toList();
    }

    public AttendanceDto checkIn() {
        Employee employee = current.currentEmployee();
        LocalDate today = LocalDate.now();
        if (attendanceRepository.findByEmployeeIdAndDate(employee.getId(), today).isPresent()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Entree deja pointee aujourd'hui");
        }
        LocalTime now = LocalTime.now().withNano(0);
        Attendance attendance = new Attendance();
        attendance.setEmployee(employee);
        attendance.setDate(today);
        attendance.setCheckInTime(now);
        attendance.setStatus(now.isAfter(LocalTime.of(9, 15)) ? AttendanceStatus.EN_RETARD : AttendanceStatus.PRESENT);
        return mapper.toAttendanceDto(attendanceRepository.save(attendance));
    }

    public AttendanceDto checkOut() {
        Employee employee = current.currentEmployee();
        LocalDate today = LocalDate.now();
        Attendance attendance = attendanceRepository.findByEmployeeIdAndDate(employee.getId(), today)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Vous devez pointer l'entree avant la sortie"));
        if (attendance.getCheckOutTime() != null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Sortie deja pointee aujourd'hui");
        }
        LocalTime now = LocalTime.now().withNano(0);
        attendance.setCheckOutTime(now);
        long minutes = Duration.between(attendance.getCheckInTime(), now).toMinutes();
        attendance.setTotalHours(BigDecimal.valueOf(minutes / 60.0).setScale(2, RoundingMode.HALF_UP));
        attendance.setStatus(AttendanceStatus.SORTI);
        return mapper.toAttendanceDto(attendanceRepository.save(attendance));
    }

    @Transactional(readOnly = true)
    public Map<String, Object> today() {
        Employee employee = current.currentEmployee();
        return attendanceRepository.findByEmployeeIdAndDate(employee.getId(), LocalDate.now())
                .map(a -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("date", a.getDate());
                    map.put("status", a.getStatus());
                    map.put("checkInTime", a.getCheckInTime());
                    map.put("checkOutTime", a.getCheckOutTime());
                    map.put("totalHours", a.getTotalHours());
                    return map;
                })
                .orElseGet(() -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("date", LocalDate.now());
                    map.put("status", AttendanceStatus.ABSENT);
                    return map;
                });
    }
}
