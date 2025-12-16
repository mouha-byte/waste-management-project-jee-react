package com.waste.service;

import com.waste.model.Incident;
import com.waste.repository.IncidentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class IncidentService {

    private final IncidentRepository repository;
    private final EmailService emailService;
    
    // Hardcoded Admin Email for simplicity, or fetch from DB config
    private static final String ADMIN_EMAIL = "mouhanedmliki6@gmail.com";

    public Incident reportIncident(Incident incident, String reporterId) {
        incident.setReporterId(reporterId);
        incident.setDate(LocalDateTime.now());
        
        Incident saved = repository.save(incident);
        log.info("Incident reported by {}: {}", reporterId, incident.getType());
        
        // Send Email Alert
        String subject = "URGENT: New Incident Reported - " + incident.getType();
        String body = "An incident has been reported by Driver " + reporterId + ".\n\n" +
                      "Type: " + incident.getType() + "\n" +
                      "Description: " + incident.getDescription() + "\n" +
                      "Date: " + incident.getDate() + "\n" +
                      "Location: " + incident.getLocation() + "\n\n" +
                      "Please check the dashboard for more details.";
                      
        emailService.sendAlertEmail(ADMIN_EMAIL, subject, body);
        
        return saved;
    }

    public List<Incident> getAllIncidents() {
        return repository.findAll();
    }

    public void deleteIncident(String id) {
        repository.deleteById(id);
        log.info("Incident {} deleted.", id);
    }
}
