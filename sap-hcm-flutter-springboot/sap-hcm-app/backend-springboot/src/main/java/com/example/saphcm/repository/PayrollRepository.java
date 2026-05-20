package com.example.saphcm.repository;

import com.example.saphcm.entity.Payroll;
import com.example.saphcm.enums.PayrollStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PayrollRepository extends JpaRepository<Payroll, Long> {
    List<Payroll> findByEmployeeIdOrderByMonthDesc(Long employeeId);

    @Query("select coalesce(sum(p.netSalary), 0) from Payroll p where p.status = :status")
    BigDecimal sumNetSalaryByStatus(PayrollStatus status);
}
