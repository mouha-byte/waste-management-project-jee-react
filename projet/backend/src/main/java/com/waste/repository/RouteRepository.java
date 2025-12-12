package com.waste.repository;

import com.waste.model.Route;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface RouteRepository extends MongoRepository<Route, String> {
    
    List<Route> findByStatus(Route.RouteStatus status);
    
    List<Route> findByDate(LocalDate date);
    
    List<Route> findByVehicleId(String vehicleId);
}
