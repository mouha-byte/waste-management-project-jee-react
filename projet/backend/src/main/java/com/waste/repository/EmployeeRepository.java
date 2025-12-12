package com.waste.repository;

import com.waste.model.Employee;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EmployeeRepository extends MongoRepository<Employee, String> {
    
    List<Employee> findByAvailable(boolean available);
    

    
    List<Employee> findByRole(Employee.Role role);
}
