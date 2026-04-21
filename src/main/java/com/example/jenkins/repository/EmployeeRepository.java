package com.example.jenkins.repository;



import com.example.jenkins.model.Employee;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class EmployeeRepository {

    private final Map<Long, Employee> employeeMap = new HashMap<>();

    public List<Employee> findAll() {
        return new ArrayList<>(employeeMap.values());
    }

    public Optional<Employee> findById(Long id) {
        return Optional.ofNullable(employeeMap.get(id));
    }

    public Employee save(Employee employee) {
        employeeMap.put(employee.getId(), employee);
        return employee;
    }

    public void delete(Long id) {
        employeeMap.remove(id);
    }
}