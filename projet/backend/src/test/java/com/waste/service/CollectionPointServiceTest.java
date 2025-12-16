package com.waste.service;

import com.waste.model.CollectionPoint;
import com.waste.model.Location;
import com.waste.repository.CollectionPointRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CollectionPointServiceTest {
    
    @Mock
    private CollectionPointRepository repository;
    
    @InjectMocks
    private CollectionPointService service;
    
    private CollectionPoint testPoint;
    
    @BeforeEach
    void setUp() {
        Location location = new Location(48.8566, 2.3522, "123 Rue de Paris");
        testPoint = new CollectionPoint(
                "1",
                location,
                CollectionPoint.WasteType.PLASTIC,
                1000.0, // Default Capacity
                95,
                CollectionPoint.Status.ACTIVE,
                LocalDateTime.now()
        );
    }
    
    @Test
    void testNeedsAlert_WhenFillLevelAbove90_ShouldReturnTrue() {
        // Given
        testPoint.setFillLevel(95);
        
        // When
        boolean needsAlert = testPoint.needsAlert();
        
        // Then
        assertTrue(needsAlert, "Container with 95% fill level should trigger alert");
    }
    
    @Test
    void testNeedsAlert_WhenFillLevelBelow90_ShouldReturnFalse() {
        // Given
        testPoint.setFillLevel(75);
        
        // When
        boolean needsAlert = testPoint.needsAlert();
        
        // Then
        assertFalse(needsAlert, "Container with 75% fill level should not trigger alert");
    }
    
    @Test
    void testGetAlerts_ShouldReturnOnlyFullContainers() {
        // Given
        CollectionPoint fullPoint1 = new CollectionPoint();
        fullPoint1.setId("1");
        fullPoint1.setFillLevel(92);
        fullPoint1.setLocation(new Location(48.8566, 2.3522, "Address 1"));
        
        CollectionPoint fullPoint2 = new CollectionPoint();
        fullPoint2.setId("2");
        fullPoint2.setFillLevel(97);
        fullPoint2.setLocation(new Location(48.8567, 2.3523, "Address 2"));
        
        when(repository.findByFillLevelGreaterThanEqual(90))
                .thenReturn(Arrays.asList(fullPoint1, fullPoint2));
        
        // When
        var alerts = service.getAlerts();
        
        // Then
        assertEquals(2, alerts.size());
        assertEquals("FullContainer", alerts.get(0).getAlertType());
        verify(repository, times(1)).findByFillLevelGreaterThanEqual(90);
    }
    
    @Test
    void testGetPointsNeedingCollection_ShouldReturnPointsAbove80Percent() {
        // Given
        CollectionPoint point1 = new CollectionPoint();
        point1.setFillLevel(85);
        
        CollectionPoint point2 = new CollectionPoint();
        point2.setFillLevel(92);
        
        when(repository.findByFillLevelGreaterThanEqual(80))
                .thenReturn(Arrays.asList(point1, point2));
        
        // When
        List<CollectionPoint> needyPoints = service.getPointsNeedingCollection();
        
        // Then
        assertEquals(2, needyPoints.size());
        verify(repository, times(1)).findByFillLevelGreaterThanEqual(80);
    }
}
