package com.waste.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "routes")
public class Route {
    
    
    @Id
    private String id;
    
    @Indexed
    private RouteStatus status;
    
    @Indexed
    private LocalDate date;
    
    private String vehicleId;
    
    // Embedded Vehicle Data
    private double cachedVehicleCapacity;
    
    private List<String> employeeIds;
    
    private List<RoutePoint> pointsToCollect;
    
    private double estimatedDistanceKm;
    
    private Location depotLocation; // Starting point for the route
    
    public enum RouteStatus {
        PLANNED, IN_PROGRESS, COMPLETED
    }
}
