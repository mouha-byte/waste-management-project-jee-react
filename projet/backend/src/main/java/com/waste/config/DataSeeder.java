package com.waste.config;

import com.waste.model.*;
import com.waste.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
@Log4j2
public class DataSeeder implements CommandLineRunner {

    private final CollectionPointRepository pointRepository;
    private final EmployeeRepository employeeRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (pointRepository.count() == 0) {
            log.info("Seeding database with initial data...");
            seedUsers();
            seedCollectionPoints();
            seedEmployees();
            seedVehicles();
            log.info("Database seeding completed.");
        }
    }

    private void seedUsers() {
        if (userRepository.findByUsername("admin").isEmpty()) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(User.Role.ADMIN);
            userRepository.save(admin);
        }
        if (userRepository.findByUsername("manager").isEmpty()) {
            User manager = new User();
            manager.setUsername("manager");
            manager.setPassword(passwordEncoder.encode("manager123"));
            manager.setRole(User.Role.MANAGER);
            userRepository.save(manager);
        }
        if (userRepository.findByUsername("driver").isEmpty()) {
            User driver = new User();
            driver.setUsername("driver");
            driver.setPassword(passwordEncoder.encode("driver123"));
            driver.setRole(User.Role.DRIVER);
            userRepository.save(driver);
        }
    }

    private void seedCollectionPoints() {
        List<CollectionPoint> points = Arrays.asList(
            createPoint("123 Rue de Paris", 36.8065, 10.1815, CollectionPoint.WasteType.PLASTIC, 95),
            createPoint("45 Avenue Habib Bourguiba", 36.8000, 10.1800, CollectionPoint.WasteType.GLASS, 40),
            createPoint("10 Rue de Marseille", 36.8100, 10.1850, CollectionPoint.WasteType.ORGANIC, 85),
            createPoint("Place de la Kasbah", 36.7980, 10.1700, CollectionPoint.WasteType.GENERAL, 20),
            createPoint("Lac 1", 36.8300, 10.2300, CollectionPoint.WasteType.PLASTIC, 92),
            createPoint("Carthage", 36.8500, 10.3200, CollectionPoint.WasteType.GLASS, 10),
            createPoint("Sidi Bou Said", 36.8700, 10.3400, CollectionPoint.WasteType.ORGANIC, 75),
            createPoint("La Marsa", 36.8800, 10.3300, CollectionPoint.WasteType.GENERAL, 60),
            createPoint("Ariana Centre", 36.8600, 10.1900, CollectionPoint.WasteType.PLASTIC, 88),
            createPoint("Manar 2", 36.8400, 10.1500, CollectionPoint.WasteType.GLASS, 30)
        );
        pointRepository.saveAll(points);
    }

    private CollectionPoint createPoint(String address, double lat, double lon, CollectionPoint.WasteType type, int fill) {
        CollectionPoint point = new CollectionPoint();
        point.setLocation(new Location(lat, lon, address));
        point.setWasteType(type);
        point.setFillLevel(fill);
        point.setStatus(CollectionPoint.Status.ACTIVE);
        point.setLastEmptied(LocalDateTime.now().minusDays(1));
        return point;
    }

    private void seedEmployees() {
        List<Employee> employees = Arrays.asList(
            createEmployee("Ahmed Ben Ali", Employee.Role.DRIVER),
            createEmployee("Sami Tounsi", Employee.Role.COLLECTOR),
            createEmployee("Karim Khelil", Employee.Role.DRIVER),
            createEmployee("Mouna Jlassi", Employee.Role.COLLECTOR)
        );
        employeeRepository.saveAll(employees);
    }

    private Employee createEmployee(String name, Employee.Role role) {
        Employee emp = new Employee();
        emp.setName(name);
        emp.setRole(role);
        emp.setAvailable(true);
        return emp;
    }

    private void seedVehicles() {
        List<Vehicle> vehicles = Arrays.asList(
            createVehicle("123-TN-4567", 5000),
            createVehicle("890-TN-1234", 3000),
            createVehicle("567-TN-8901", 8000)
        );
        vehicleRepository.saveAll(vehicles);
    }

    private Vehicle createVehicle(String plate, int capacity) {
        Vehicle v = new Vehicle();
        v.setPlateNumber(plate);
        v.setCapacity(capacity);
        v.setStatus(Vehicle.VehicleStatus.AVAILABLE);
        return v;
    }
}
