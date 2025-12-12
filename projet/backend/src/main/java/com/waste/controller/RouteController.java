package com.waste.controller;

import com.waste.model.Route;
import com.waste.service.RouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RouteController {
    
    private final RouteService service;
    
    @PostMapping
    public ResponseEntity<Route> createRoute(@RequestBody Route route) {
        Route created = service.createRoute(route);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping
    public ResponseEntity<List<Route>> getAllRoutes() {
        return ResponseEntity.ok(service.getAllRoutes());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Route> getRouteById(@PathVariable String id) {
        return service.getRouteById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Route> updateRoute(
            @PathVariable String id, 
            @RequestBody Route route) {
        Route updated = service.updateRoute(id, route);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRoute(@PathVariable String id) {
        service.deleteRoute(id);
        return ResponseEntity.noContent().build();
    }
    
    @PostMapping("/generate")
    public ResponseEntity<Route> generateOptimizedRoute() {
        try {
            Route route = service.generateOptimizedRoute();
            return ResponseEntity.status(HttpStatus.CREATED).body(route);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PatchMapping("/{id}/status")
    public ResponseEntity<Route> updateRouteStatus(
            @PathVariable String id,
            @RequestParam Route.RouteStatus status) {
        Route updated = service.updateRouteStatus(id, status);
        return ResponseEntity.ok(updated);
    }
}
