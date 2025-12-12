package com.waste.controller;

import com.waste.model.Employee;
import com.waste.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employees")
@RequiredArgsConstructor
public class EmployeeController {
    
    private final EmployeeService service;
    
    @PostMapping
    public ResponseEntity<Employee> createEmployee(@RequestBody Employee employee) {
        Employee created = service.createEmployee(employee);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping
    public ResponseEntity<List<Employee>> getAllEmployees() {
        return ResponseEntity.ok(service.getAllEmployees());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Employee> getEmployeeById(@PathVariable String id) {
        return service.getEmployeeById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Employee> updateEmployee(
            @PathVariable String id, 
            @RequestBody Employee employee) {
        Employee updated = service.updateEmployee(id, employee);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEmployee(@PathVariable String id) {
        service.deleteEmployee(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/available")
    public ResponseEntity<List<Employee>> getAvailableEmployees() {
        return ResponseEntity.ok(service.getAvailableEmployees());
    }
    
    // Endpoint deprecated
    // @PostMapping("/{id}/auto-assign-zone") ...
}
