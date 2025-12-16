package com.waste.controller;

import lombok.Data;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.management.ManagementFactory;
import java.lang.management.OperatingSystemMXBean;
import java.lang.management.RuntimeMXBean;

@RestController
@RequestMapping("/api/monitoring")
public class MonitoringController {

    @GetMapping("/health")
    // @PreAuthorize("hasRole('ADMIN')") // Removed for public access
    public ResponseEntity<SystemHealth> getSystemHealth() {
        SystemHealth health = new SystemHealth();
        
        // Memory (Java Heap)
        Runtime runtime = Runtime.getRuntime();
        health.setTotalMemory(runtime.totalMemory());
        health.setFreeMemory(runtime.freeMemory());
        health.setMaxMemory(runtime.maxMemory());
        health.setUsedMemory(runtime.totalMemory() - runtime.freeMemory());
        
        // Uptime
        RuntimeMXBean runtimeMX = ManagementFactory.getRuntimeMXBean();
        health.setUptime(runtimeMX.getUptime());
        
        // System Load (CPU)
        OperatingSystemMXBean osMX = ManagementFactory.getPlatformMXBean(OperatingSystemMXBean.class);
        health.setSystemLoad(osMX.getSystemLoadAverage());
        health.setAvailableProcessors(osMX.getAvailableProcessors());
        
        // Threads
        health.setActiveThreads(Thread.activeCount());
        
        return ResponseEntity.ok(health);
    }
    
    @Data
    static class SystemHealth {
        private long totalMemory;
        private long freeMemory;
        private long maxMemory;
        private long usedMemory;
        private long uptime;         // milliseconds
        private double systemLoad;   // average load
        private int availableProcessors;
        private int activeThreads;
    }
}
