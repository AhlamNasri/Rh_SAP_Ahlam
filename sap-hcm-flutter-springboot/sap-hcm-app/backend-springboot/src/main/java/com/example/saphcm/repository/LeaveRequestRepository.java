package com.example.saphcm.repository;

import com.example.saphcm.entity.LeaveRequest;
import com.example.saphcm.enums.LeaveStatus;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {

    List<LeaveRequest> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);
    List<LeaveRequest> findByEmployeeManagerIdOrderByCreatedAtDesc(Long managerId);
    long countByStatus(LeaveStatus status);

    @Query("select month(l.startDate), count(l) from LeaveRequest l group by month(l.startDate) order by month(l.startDate)")
    List<Object[]> countByMonth();
}
