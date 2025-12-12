package com.waste.service;

import com.waste.dto.AlertResponse;
import com.waste.model.CollectionPoint;
import com.waste.repository.CollectionPointRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Log4j2
public class CollectionPointService {
    
    private final CollectionPointRepository repository;
    private final EmailService emailService;
    
    public CollectionPoint createPoint(CollectionPoint point) {
        log.info("Creating new collection point at {}", point.getLocation().getAddress());
        CollectionPoint saved = repository.save(point);
        
        if (saved.needsAlert()) {
            log.warn("New collection point {} already needs attention - fill level: {}%", 
                    saved.getId(), saved.getFillLevel());
            sendAlert(saved);
        }
        
        return saved;
    }
    
    public List<CollectionPoint> getAllPoints() {
        log.debug("Fetching all collection points");
        return repository.findAll();
    }
    
    public Optional<CollectionPoint> getPointById(String id) {
        log.debug("Fetching collection point with id: {}", id);
        return repository.findById(id);
    }
    
    public CollectionPoint updatePoint(String id, CollectionPoint point) {
        log.info("Updating collection point {}", id);
        point.setId(id);
        CollectionPoint updated = repository.save(point);
        
        if (updated.needsAlert()) {
            log.warn("Collection point {} needs attention - fill level: {}%", 
                    updated.getId(), updated.getFillLevel());
            sendAlert(updated);
        }
        
        return updated;
    }

    private void sendAlert(CollectionPoint point) {
        String subject = "🚨 ALERT: Container Full - " + point.getId();
        String body = String.format("Container at %s is %d%% full.\nType: %s\nStatus: %s\nPlease schedule collection immediately.",
                point.getLocation().getAddress(),
                point.getFillLevel(),
                point.getWasteType(),
                point.getStatus());
        
        emailService.sendAlertEmail("mouhanedmliki6@gmail.com", subject, body);
    }
    
    public void deletePoint(String id) {
        log.info("Deleting collection point {}", id);
        repository.deleteById(id);
    }
    
    public List<AlertResponse> getAlerts() {
        log.debug("Fetching alerts for collection points");
        List<CollectionPoint> fullPoints = repository.findByFillLevelGreaterThanEqual(90);
        
        return fullPoints.stream()
                .map(point -> new AlertResponse(
                        "FullContainer",
                        point.getId(),
                        point.getFillLevel() >= 95 ? "HIGH" : "MEDIUM",
                        point.getFillLevel(),
                        String.format("Container at %s is %d%% full", 
                                point.getLocation().getAddress(), point.getFillLevel())
                ))
                .collect(Collectors.toList());
    }
    
    public List<CollectionPoint> getPointsNeedingCollection() {
        log.debug("Fetching points needing collection (>80% full)");
        return repository.findByFillLevelGreaterThanEqual(80);
    }
}
