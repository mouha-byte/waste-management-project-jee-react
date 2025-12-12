package com.waste.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoutePoint {
    private String pointId;
    private Priority priority;
    
    // Embedded data for read optimization (NoSQL Pattern)
    private String cachedAddress;
    private CollectionPoint.WasteType cachedWasteType;
    private double cachedCapacity; // Volume in kg
    
    public enum Priority {
        LOW, MEDIUM, HIGH
    }
}
