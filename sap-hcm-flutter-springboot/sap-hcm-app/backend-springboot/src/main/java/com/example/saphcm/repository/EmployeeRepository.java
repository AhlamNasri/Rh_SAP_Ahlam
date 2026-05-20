package com.example.saphcm.repository;

import com.example.saphcm.entity.Employee;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    Optional<Employee> findByEmail(String email);
    Optional<Employee> findByEmployeeNumber(String employeeNumber);
    List<Employee> findByManagerId(Long managerId);
    long countByActiveTrue();
}
