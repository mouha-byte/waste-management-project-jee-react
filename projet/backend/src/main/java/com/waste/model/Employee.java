package com.waste.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "employees")
public class Employee {
    
    @Id
    private String id;
    
    private String name;
    
    @Indexed
    private Role role;
    

    @Indexed
    private boolean available;
    
    private List<CollectionPoint.WasteType> competencies;
    
    public enum Role {
        DRIVER, COLLECTOR
    }
}
