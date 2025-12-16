package com.waste.controller;

import com.waste.model.Incident;
import com.waste.service.IncidentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/incidents")
@RequiredArgsConstructor
public class IncidentController {

    private final IncidentService service;

    @PostMapping
    @PreAuthorize("hasAnyRole('DRIVER', 'MANAGER', 'ADMIN')") // Drivers report, but admins can too
    public ResponseEntity<Incident> reportIncident(@RequestBody Incident incident, Authentication authentication) {
        // In a real app, we'd map the User ID from Authentication to an Employee ID
        // For now, we use the username as reporterId
        String info = authentication.getName();
        return ResponseEntity.ok(service.reportIncident(incident, info));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<List<Incident>> getAllIncidents() {
        return ResponseEntity.ok(service.getAllIncidents());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Void> deleteIncident(@PathVariable String id) {
        service.deleteIncident(id);
        return ResponseEntity.noContent().build();
    }
}
