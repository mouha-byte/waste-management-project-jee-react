package com.waste.service;

import com.waste.model.*;
import com.waste.repository.RouteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RouteServiceTest {
    
    @Mock
    private RouteRepository routeRepository;
    
    @Mock
    private CollectionPointService collectionPointService;
    
    @Mock
    private VehicleService vehicleService;
    
    @Mock
    private EmployeeService employeeService;
    
    @InjectMocks
    private RouteService routeService;
    
    @Test
    void testGenerateOptimizedRoute_ShouldIncludeOnlyFullContainers() {
        // Given
        CollectionPoint point1 = new CollectionPoint();
        point1.setId("point1");
        point1.setFillLevel(85);
        point1.setLocation(new Location(36.8, 10.1, "Address 1"));
        
        CollectionPoint point2 = new CollectionPoint();
        point2.setId("point2");
        point2.setFillLevel(95);
        point2.setLocation(new Location(36.8, 10.1, "Address 2"));
        
        CollectionPoint point3 = new CollectionPoint();
        point3.setId("point3");
        point3.setFillLevel(82);
        point3.setLocation(new Location(36.8, 10.1, "Address 3"));
        
        List<CollectionPoint> needyPoints = Arrays.asList(point1, point2, point3);
        
        Vehicle vehicle = new Vehicle();
        vehicle.setId("vehicle1");
        vehicle.setCapacity(3000); // Increased capacity to fit all points (Total ~2620kg)
        vehicle.setPlateNumber("AB-123-CD");
        
        Employee employee = new Employee();
        employee.setId("emp1");
        employee.setRole(Employee.Role.DRIVER); // Must be DRIVER for new logic
        
        when(collectionPointService.getPointsNeedingCollection()).thenReturn(needyPoints);
        when(vehicleService.getAvailableVehicles()).thenReturn(Arrays.asList(vehicle));
        when(employeeService.getAvailableEmployees()).thenReturn(Arrays.asList(employee));
        when(routeRepository.save(any(Route.class))).thenAnswer(i -> i.getArguments()[0]);
        
        // When
        Route route = routeService.generateOptimizedRoute();
        
        // Then
        assertNotNull(route);
        assertEquals(3, route.getPointsToCollect().size());
        assertEquals(Route.RouteStatus.PLANNED, route.getStatus());
        assertEquals("vehicle1", route.getVehicleId());
        
        // Verify highest fill level is first (95%)
        assertEquals("point2", route.getPointsToCollect().get(0).getPointId());
        assertEquals(RoutePoint.Priority.HIGH, route.getPointsToCollect().get(0).getPriority());
        
        verify(collectionPointService, times(1)).getPointsNeedingCollection();
        verify(vehicleService, times(1)).getAvailableVehicles();
        verify(employeeService, times(1)).getAvailableEmployees();
        verify(routeRepository, times(1)).save(any(Route.class));
    }
    
    @Test
    void testGenerateOptimizedRoute_WhenNoContainersNeedCollection_ShouldThrowException() {
        // Given
        when(collectionPointService.getPointsNeedingCollection()).thenReturn(Arrays.asList());
        
        // When & Then
        assertThrows(RuntimeException.class, () -> {
            routeService.generateOptimizedRoute();
        });
        
        verify(collectionPointService, times(1)).getPointsNeedingCollection();
        verify(vehicleService, never()).getAvailableVehicles();
    }
}
