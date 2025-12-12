package com.waste.controller;

import com.waste.dto.AlertResponse;
import com.waste.model.CollectionPoint;
import com.waste.service.CollectionPointService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/points")
@RequiredArgsConstructor
public class CollectionPointController {
    
    private final CollectionPointService service;
    
    @PostMapping
    public ResponseEntity<CollectionPoint> createPoint(@RequestBody CollectionPoint point) {
        CollectionPoint created = service.createPoint(point);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping
    public ResponseEntity<List<CollectionPoint>> getAllPoints() {
        return ResponseEntity.ok(service.getAllPoints());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<CollectionPoint> getPointById(@PathVariable String id) {
        return service.getPointById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<CollectionPoint> updatePoint(
            @PathVariable String id, 
            @RequestBody CollectionPoint point) {
        CollectionPoint updated = service.updatePoint(id, point);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePoint(@PathVariable String id) {
        service.deletePoint(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/alerts")
    public ResponseEntity<List<AlertResponse>> getAlerts() {
        return ResponseEntity.ok(service.getAlerts());
    }
    
    @GetMapping("/needing-collection")
    public ResponseEntity<List<CollectionPoint>> getPointsNeedingCollection() {
        return ResponseEntity.ok(service.getPointsNeedingCollection());
    }
}
