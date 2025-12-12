package com.waste.service;

import com.waste.model.*;
import com.waste.repository.RouteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Log4j2
public class RouteService {
    
    private final RouteRepository repository;
    private final CollectionPointService collectionPointService;
    private final VehicleService vehicleService;
    private final EmployeeService employeeService;
    
    public Route createRoute(Route route) {
        log.info("Creating new route for date: {}", route.getDate());
        return repository.save(route);
    }
    
    public List<Route> getAllRoutes() {
        log.debug("Fetching all routes");
        return repository.findAll();
    }
    
    public Optional<Route> getRouteById(String id) {
        log.debug("Fetching route with id: {}", id);
        return repository.findById(id);
    }
    
    public Route updateRoute(String id, Route route) {
        log.info("Updating route {}", id);
        route.setId(id);
        return repository.save(route);
    }
    
    public void deleteRoute(String id) {
        log.info("Deleting route {}", id);
        repository.deleteById(id);
    }
    
    /**
     * Generate an optimized route based on container fill levels
     * Simple algorithm:
     * 1. Get all containers > 80% full
     * 2. Sort by fill level (highest first)
     * 3. Assign available vehicle with highest capacity
     * 4. Assign available employees
     */
    public Route generateOptimizedRoute() {
        log.info("Generating optimized route");
        
        // Get containers needing collection (>80% full)
        List<CollectionPoint> needyPoints = collectionPointService.getPointsNeedingCollection();
        
        if (needyPoints.isEmpty()) {
            log.info("No containers need collection at this time");
            throw new RuntimeException("No containers need collection");
        }
        
        // Sort by fill level (highest priority first)
        List<CollectionPoint> sortedPoints = needyPoints.stream()
                .sorted(Comparator.comparingInt(CollectionPoint::getFillLevel).reversed())
                .collect(Collectors.toList());
        
        // Get available vehicle with highest capacity
        List<Vehicle> availableVehicles = vehicleService.getAvailableVehicles();
        if (availableVehicles.isEmpty()) {
            log.error("No vehicles available for route generation");
            throw new RuntimeException("No vehicles available");
        }
        
        Vehicle selectedVehicle = availableVehicles.stream()
                .max(Comparator.comparingInt(Vehicle::getCapacity))
                .orElseThrow();
        
        // Assign Crew: 1 Driver + Max 2 Collectors
        List<Employee> availableEmployees = employeeService.getAvailableEmployees();
        
        List<Employee> drivers = availableEmployees.stream()
                .filter(e -> e.getRole() == Employee.Role.DRIVER)
                .limit(1)
                .collect(Collectors.toList());
                
        if (drivers.isEmpty()) {
            log.error("No drivers available for route generation");
            throw new RuntimeException("No drivers available");
        }
        
        List<Employee> collectors = availableEmployees.stream()
                .filter(e -> e.getRole() == Employee.Role.COLLECTOR)
                .limit(2)
                .collect(Collectors.toList());
                
        List<String> assignedIds = new ArrayList<>();
        assignedIds.add(drivers.get(0).getId());
        collectors.forEach(c -> assignedIds.add(c.getId()));
        
        // Initialize Route Accumulators
        List<RoutePoint> routePoints = new ArrayList<>();
        double currentLoadKg = 0.0;
        double vehicleCapacityKg = selectedVehicle.getCapacity();
        
        // Select points that fit in the vehicle
        for (CollectionPoint point : sortedPoints) {
            
            // Calculate estimated waste weight: (Fill % / 100) * Capacity
            double fillRatio = point.getFillLevel() / 100.0;
            double estimatedWeight = fillRatio * point.getCapacity();
            
            // Check if adding this point exceeds vehicle capacity
            if (currentLoadKg + estimatedWeight <= vehicleCapacityKg) {
                
                // Add to route
                RoutePoint.Priority priority;
                if (point.getFillLevel() >= 95) {
                    priority = RoutePoint.Priority.HIGH;
                } else if (point.getFillLevel() >= 85) {
                    priority = RoutePoint.Priority.MEDIUM;
                } else {
                    priority = RoutePoint.Priority.LOW;
                }
                
                RoutePoint rp = new RoutePoint();
                rp.setPointId(point.getId());
                rp.setPriority(priority);
                // Populate embedded data
                rp.setCachedAddress(point.getLocation().getAddress());
                rp.setCachedWasteType(point.getWasteType());
                rp.setCachedCapacity(point.getCapacity());
                
                routePoints.add(rp);
                currentLoadKg += estimatedWeight;
            } else {
                log.debug("Skipping point {} ({} kg): Vehicle full (Current: {}/{})", 
                        point.getId(), estimatedWeight, currentLoadKg, vehicleCapacityKg);
            }
        }
        
        if (routePoints.isEmpty()) {
            // Edge case: Even the first point didn't fit (unlikely if sorted, but possible)
            log.warn("No points fit in the selected vehicle.");
             // Fallback or just return empty route? 
             // Ideally we should try to at least take one or warn. 
             // For now, let's proceed, emptiness check might handle it downstream if strict.
        }
        
        // Simple distance estimation (in real app, use proper routing API)
        double estimatedDistance = routePoints.size() * 2.5; // 2.5 km per stop average
        
        // Create route
        Route route = new Route();
        route.setStatus(Route.RouteStatus.PLANNED);
        route.setDate(LocalDate.now());
        route.setVehicleId(selectedVehicle.getId());
        route.setCachedVehicleCapacity(selectedVehicle.getCapacity());
        route.setEmployeeIds(assignedIds);
        route.setPointsToCollect(routePoints);
        route.setEstimatedDistanceKm(estimatedDistance);
        
        // Set depot location (default central depot in Tunis)
        Location depot = new Location();
        depot.setLatitude(36.8065);
        depot.setLongitude(10.1815);
        depot.setAddress("Central Depot - Tunis");
        route.setDepotLocation(depot);
        
        Route saved = repository.save(route);
        
        log.info("Route generated: {} points, Load: {}/{} kg, vehicle {}", 
                routePoints.size(), String.format("%.2f", currentLoadKg), vehicleCapacityKg, selectedVehicle.getPlateNumber());
        
        return saved;
    }
    
    public Route updateRouteStatus(String id, Route.RouteStatus status) {
        log.info("Updating route {} status to {}", id, status);
        
        Optional<Route> routeOpt = repository.findById(id);
        if (routeOpt.isEmpty()) {
            throw new RuntimeException("Route not found");
        }
        
        Route route = routeOpt.get();
        Route.RouteStatus oldStatus = route.getStatus();
        route.setStatus(status);
        
        // Handle side effects
        if (status == Route.RouteStatus.IN_PROGRESS && oldStatus == Route.RouteStatus.PLANNED) {
            // Lock resources
            updateResources(route, true);
        } else if (status == Route.RouteStatus.COMPLETED && oldStatus == Route.RouteStatus.IN_PROGRESS) {
            // Release resources
            updateResources(route, false);
            // Empty containers
            emptyContainers(route);
        }
        
        return repository.save(route);
    }

    private void updateResources(Route route, boolean inUse) {
        // Update Vehicle
        if (route.getVehicleId() != null) {
            vehicleService.getVehicleById(route.getVehicleId()).ifPresent(vehicle -> {
                vehicle.setStatus(inUse ? Vehicle.VehicleStatus.IN_USE : Vehicle.VehicleStatus.AVAILABLE);
                vehicleService.updateVehicle(vehicle.getId(), vehicle);
            });
        }

        // Update Employees
        if (route.getEmployeeIds() != null) {
            for (String empId : route.getEmployeeIds()) {
                employeeService.getEmployeeById(empId).ifPresent(employee -> {
                    employee.setAvailable(!inUse);
                    employeeService.updateEmployee(employee.getId(), employee);
                });
            }
        }
    }

    private void emptyContainers(Route route) {
        if (route.getPointsToCollect() != null) {
            for (RoutePoint rp : route.getPointsToCollect()) {
                collectionPointService.getPointById(rp.getPointId()).ifPresent(point -> {
                    point.setFillLevel(0);
                    point.setLastEmptied(java.time.LocalDateTime.now());
                    collectionPointService.updatePoint(point.getId(), point);
                });
            }
        }
    }
}
