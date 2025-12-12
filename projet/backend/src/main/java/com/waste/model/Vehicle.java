package com.waste.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "vehicles")
public class Vehicle {
    
    @Id
    private String id;
    
    private String plateNumber;
    
    private int capacity; // in liters or kg
    
    private VehicleStatus status;
    
    private Location currentLocation;
    
    public enum VehicleStatus {
        AVAILABLE, IN_USE, MAINTENANCE
    }
}
