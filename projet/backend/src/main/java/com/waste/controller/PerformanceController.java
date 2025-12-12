package com.waste.controller;

import com.waste.model.*;
import com.waste.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/performance")
@RequiredArgsConstructor
public class PerformanceController {

    private final CollectionPointRepository pointRepository;
    private final EmployeeRepository employeeRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;
    private final RouteRepository routeRepository;
    private final PasswordEncoder passwordEncoder;
    
    private final Random random = new Random();

    @PostMapping("/seed-points")
    public ResponseEntity<String> seedPoints(@RequestParam(defaultValue = "1000") int count) {
        List<CollectionPoint> points = new ArrayList<>();
        double baseLat = 36.8065;
        double baseLon = 10.1815;

        for (int i = 0; i < count; i++) {
            CollectionPoint p = new CollectionPoint();
            double lat = baseLat + (random.nextDouble() - 0.5) * 0.1;
            double lon = baseLon + (random.nextDouble() - 0.5) * 0.1;
            
            p.setLocation(new Location(lat, lon, "Gen. Address " + UUID.randomUUID().toString().substring(0, 5)));
            p.setWasteType(CollectionPoint.WasteType.values()[random.nextInt(CollectionPoint.WasteType.values().length)]);
            p.setWasteType(CollectionPoint.WasteType.values()[random.nextInt(CollectionPoint.WasteType.values().length)]);
            p.setFillLevel(random.nextInt(101));
            // Random Capacity: 500, 1000, or 1500 kg
            int[] capacities = {500, 1000, 1500};
            p.setCapacity(capacities[random.nextInt(capacities.length)]);
            
            p.setStatus(CollectionPoint.Status.ACTIVE);
            p.setLastEmptied(LocalDateTime.now().minusHours(random.nextInt(48)));
            points.add(p);
        }
        pointRepository.saveAll(points);
        return ResponseEntity.ok("Seeded " + count + " collection points.");
    }

    @PostMapping("/seed-employees")
    public ResponseEntity<String> seedEmployees(@RequestParam(defaultValue = "100") int count) {
        List<Employee> employees = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            Employee e = new Employee();
            e.setName("Employee " + UUID.randomUUID().toString().substring(0, 8));
            e.setRole(random.nextBoolean() ? Employee.Role.DRIVER : Employee.Role.COLLECTOR);
            e.setAvailable(random.nextBoolean());
            e.setCompetencies(new ArrayList<>()); // Simplified
            employees.add(e);
        }
        employeeRepository.saveAll(employees);
        return ResponseEntity.ok("Seeded " + count + " employees.");
    }

    @PostMapping("/seed-vehicles")
    public ResponseEntity<String> seedVehicles(@RequestParam(defaultValue = "50") int count) {
        List<Vehicle> vehicles = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            Vehicle v = new Vehicle();
            v.setPlateNumber(random.nextInt(999) + "TN" + random.nextInt(9999));
            v.setCapacity(1000 + random.nextInt(9000));
            v.setStatus(Vehicle.VehicleStatus.AVAILABLE);
            vehicles.add(v);
        }
        vehicleRepository.saveAll(vehicles);
        return ResponseEntity.ok("Seeded " + count + " vehicles.");
    }
    
    @PostMapping("/seed-users")
    public ResponseEntity<String> seedUsers(@RequestParam(defaultValue = "50") int count) {
        List<User> users = new ArrayList<>();
        String rawPassword = "password123";
        String encodedPassword = passwordEncoder.encode(rawPassword);
        
        for (int i = 0; i < count; i++) {
            User u = new User();
            u.setUsername("user_" + UUID.randomUUID().toString().substring(0, 8));
            u.setPassword(encodedPassword);
            u.setRole(User.Role.values()[random.nextInt(User.Role.values().length)]);
            users.add(u);
        }
        userRepository.saveAll(users);
        return ResponseEntity.ok("Seeded " + count + " users.");
    }

    @PostMapping("/seed-routes")
    public ResponseEntity<String> seedRoutes(@RequestParam(defaultValue = "100") int count) {
        // Needs some existing data to link, or mock references
        // We will mock references for pure performance testing or try to fetch a few
        List<Route> routes = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            Route r = new Route();
            r.setDate(LocalDate.now().minusDays(random.nextInt(30)));
            r.setStatus(Route.RouteStatus.values()[random.nextInt(Route.RouteStatus.values().length)]);
            r.setEstimatedDistanceKm(10 + random.nextDouble() * 50);
            r.setVehicleId("mock-vehicle-" + random.nextInt(100));
            r.setEmployeeIds(Collections.singletonList("mock-emp-" + random.nextInt(100)));
            r.setPointsToCollect(new ArrayList<>()); // Empty for speed
            
            // Depot
            Location depot = new Location(36.8065, 10.1815, "Central Depot");
            r.setDepotLocation(depot);
            
            routes.add(r);
        }
        routeRepository.saveAll(routes);
        return ResponseEntity.ok("Seeded " + count + " routes (Mock references).");
    }

    @PostMapping("/seed-full")
    public ResponseEntity<String> seedFull(@RequestParam(defaultValue = "1") int multiplier) {
        // Master button
        seedPoints(1000 * multiplier);
        seedVehicles(50 * multiplier);
        seedEmployees(100 * multiplier);
        seedUsers(50 * multiplier);
        seedRoutes(100 * multiplier);
        return ResponseEntity.ok("Full System Clean Seeding Complete (x" + multiplier + ")");
    }
}
