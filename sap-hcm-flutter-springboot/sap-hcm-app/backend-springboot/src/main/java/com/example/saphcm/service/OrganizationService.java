package com.example.saphcm.service;

import com.example.saphcm.entity.Department;
import com.example.saphcm.entity.Employee;
import com.example.saphcm.repository.DepartmentRepository;
import com.example.saphcm.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrganizationService {
    private final DepartmentRepository departmentRepository;
    private final EmployeeRepository employeeRepository;

    public Map<String, Object> tree() {
        Map<String, Object> root = new LinkedHashMap<>();
        root.put("label", "Direction generale");
        root.put("type", "ROOT");
        List<Map<String, Object>> departments = departmentRepository.findAll().stream().map(this::departmentNode).toList();
        root.put("children", departments);
        return root;
    }

    private Map<String, Object> departmentNode(Department dept) {
        Map<String, Object> node = new LinkedHashMap<>();
        node.put("id", dept.getId());
        node.put("label", dept.getName());
        node.put("type", "DEPARTMENT");
        List<Map<String, Object>> managers = employeeRepository.findAll().stream()
                .filter(e -> e.getDepartment() != null && e.getDepartment().getId().equals(dept.getId()))
                .filter(e -> employeeRepository.findByManagerId(e.getId()).size() > 0)
                .map(this::employeeNode)
                .toList();
        if (managers.isEmpty()) {
            managers = employeeRepository.findAll().stream()
                    .filter(e -> e.getDepartment() != null && e.getDepartment().getId().equals(dept.getId()))
                    .map(this::employeeNode)
                    .toList();
        }
        node.put("children", managers);
        return node;
    }

    private Map<String, Object> employeeNode(Employee employee) {
        Map<String, Object> node = new LinkedHashMap<>();
        node.put("id", employee.getId());
        node.put("label", employee.getFullName());
        node.put("jobTitle", employee.getJobTitle());
        node.put("type", "EMPLOYEE");
        node.put("children", employeeRepository.findByManagerId(employee.getId()).stream().map(this::employeeNode).toList());
        return node;
    }
}
