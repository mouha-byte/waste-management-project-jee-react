package com.waste.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "incidents")
public class Incident {
    
    @Id
    private String id;
    
    private String description;
    
    private IncidentType type;
    
    private String reporterId; // Driver ID
    
    private LocalDateTime date;
    
    private String location; // Optional: "Lat,Lon" or description
    
    public enum IncidentType {
        BIN_DAMAGED,
        ILLEGAL_DUMPING,
        ACCESS_BLOCKED,
        VEHICLE_ISSUE,
        OTHER
    }
}
