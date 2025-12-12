package com.waste.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "collection_points")
public class CollectionPoint {
    
    @Id
    private String id;
    
    private Location location;
    
    private WasteType wasteType;
    
    private double capacity = 1000.0; // Capacity in Kg (Default 1000)
    
    @Indexed
    private int fillLevel; // 0-100 percentage
    
    @Indexed
    private Status status;
    
    private LocalDateTime lastEmptied;
    
    public enum WasteType {
        PLASTIC, GLASS, ORGANIC, GENERAL
    }
    
    public enum Status {
        ACTIVE, MAINTENANCE, BROKEN
    }
    
    // Helper method to check if alert is needed
    public boolean needsAlert() {
        return fillLevel >= 90;
    }
}
