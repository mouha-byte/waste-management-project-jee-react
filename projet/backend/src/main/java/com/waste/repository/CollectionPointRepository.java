package com.waste.repository;

import com.waste.model.CollectionPoint;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CollectionPointRepository extends MongoRepository<CollectionPoint, String> {
    
    List<CollectionPoint> findByFillLevelGreaterThanEqual(int fillLevel);
    
    List<CollectionPoint> findByStatus(CollectionPoint.Status status);
    
    List<CollectionPoint> findByWasteType(CollectionPoint.WasteType wasteType);
}
