package com.waste.repository;

import com.waste.model.Incident;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IncidentRepository extends MongoRepository<Incident, String> {
    List<Incident> findByReporterId(String reporterId);
    List<Incident> findByType(Incident.IncidentType type);
}
