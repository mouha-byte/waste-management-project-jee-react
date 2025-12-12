package com.waste.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AlertResponse {
    private String alertType;
    private String containerId;
    private String priority;
    private int fillLevel;
    private String message;
}
