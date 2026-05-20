package com.example.saphcm.repository;

import com.example.saphcm.entity.Attendance;
import com.example.saphcm.enums.AttendanceStatus;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    List<Attendance> findByEmployeeIdOrderByDateDescIdDesc(Long employeeId);
    List<Attendance> findByEmployeeManagerIdOrderByDateDesc(Long managerId);
    Optional<Attendance> findByEmployeeIdAndDate(Long employeeId, LocalDate date);
    long countByDateAndStatusIn(LocalDate date, Collection<AttendanceStatus> statuses);

    @Query("select a.date, count(a) from Attendance a where a.date >= :fromDate group by a.date order by a.date")
    List<Object[]> summarizeFrom(LocalDate fromDate);
}
