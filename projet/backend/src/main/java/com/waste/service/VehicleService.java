package com.waste.service;

import com.waste.model.Vehicle;
import com.waste.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Log4j2
public class VehicleService {
    
    private final VehicleRepository repository;
    
    public Vehicle createVehicle(Vehicle vehicle) {
        log.info("Creating new vehicle: {}", vehicle.getPlateNumber());
        return repository.save(vehicle);
    }
    
    public List<Vehicle> getAllVehicles() {
        log.debug("Fetching all vehicles");
        return repository.findAll();
    }
    
    public Optional<Vehicle> getVehicleById(String id) {
        log.debug("Fetching vehicle with id: {}", id);
        return repository.findById(id);
    }
    
    public Vehicle updateVehicle(String id, Vehicle vehicle) {
        log.info("Updating vehicle {}", id);
        vehicle.setId(id);
        return repository.save(vehicle);
    }
    
    public void deleteVehicle(String id) {
        log.info("Deleting vehicle {}", id);
        repository.deleteById(id);
    }
    
    public List<Vehicle> getAvailableVehicles() {
        log.debug("Fetching available vehicles");
        return repository.findByStatus(Vehicle.VehicleStatus.AVAILABLE);
    }
}
