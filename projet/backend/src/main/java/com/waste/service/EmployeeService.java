package com.waste.service;

import com.waste.model.CollectionPoint;
import com.waste.model.Employee;
import com.waste.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Log4j2
public class EmployeeService {
    
    private final EmployeeRepository repository;
    private final CollectionPointService collectionPointService;
    
    public Employee createEmployee(Employee employee) {
        log.info("Creating new employee: {}", employee.getName());
        return repository.save(employee);
    }
    
    public List<Employee> getAllEmployees() {
        log.debug("Fetching all employees");
        return repository.findAll();
    }
    
    public Optional<Employee> getEmployeeById(String id) {
        log.debug("Fetching employee with id: {}", id);
        return repository.findById(id);
    }
    
    public Employee updateEmployee(String id, Employee employee) {
        log.info("Updating employee {}", id);
        employee.setId(id);
        return repository.save(employee);
    }
    
    public void deleteEmployee(String id) {
        log.info("Deleting employee {}", id);
        repository.deleteById(id);
    }
    
    public List<Employee> getAvailableEmployees() {
        log.debug("Fetching available employees");
        return repository.findByAvailable(true);
    }
    
    // Auto-assignment logic has been deprecated in favor of RouteService optimization
    // public Employee autoAssignZone(String employeeId) { ... }
}
