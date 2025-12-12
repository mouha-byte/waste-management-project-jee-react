# Waste Management System - Backend

## Overview
Smart Urban Waste Management System backend built with Spring Boot and MongoDB.

## Technologies
- **Framework**: Spring Boot 3.2.0
- **Database**: MongoDB
- **Build Tool**: Maven
- **Logging**: Log4j2
- **Testing**: JUnit 5

## Prerequisites
- Java 17+
- Maven 3.6+
- MongoDB 4.4+ (running on localhost:27017)

## Project Structure
```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/waste/
│   │   │   ├── config/          # Configuration classes
│   │   │   ├── controller/      # REST Controllers
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   ├── model/           # Domain Entities
│   │   │   ├── repository/      # MongoDB Repositories
│   │   │   ├── service/         # Business Logic
│   │   │   └── WasteManagementApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── log4j2.xml
│   └── test/
│       └── java/com/waste/service/  # Unit Tests
└── pom.xml
```

## Setup & Run

### 1. Start MongoDB
```bash
# Windows (if MongoDB is installed as service)
net start MongoDB

# Or use Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### 2. Build the project
```bash
cd backend
mvn clean install
```

### 3. Run the application
```bash
mvn spring-boot:run
```

The server will start on `http://localhost:8080`

### 4. Run tests
```bash
mvn test
```

## API Endpoints

### Collection Points
- `POST /api/points` - Create a new collection point
- `GET /api/points` - Get all collection points
- `GET /api/points/{id}` - Get point by ID
- `PUT /api/points/{id}` - Update a point
- `DELETE /api/points/{id}` - Delete a point
- `GET /api/points/alerts` - Get all alerts (containers >90% full)
- `GET /api/points/needing-collection` - Get points >80% full

### Employees
- `POST /api/employees` - Create a new employee
- `GET /api/employees` - Get all employees
- `GET /api/employees/{id}` - Get employee by ID
- `PUT /api/employees/{id}` - Update an employee
- `DELETE /api/employees/{id}` - Delete an employee
- `GET /api/employees/available` - Get available employees
- `POST /api/employees/{id}/auto-assign-zone` - Auto-assign employee to best zone

### Vehicles
- `POST /api/vehicles` - Create a new vehicle
- `GET /api/vehicles` - Get all vehicles
- `GET /api/vehicles/{id}` - Get vehicle by ID
- `PUT /api/vehicles/{id}` - Update a vehicle
- `DELETE /api/vehicles/{id}` - Delete a vehicle
- `GET /api/vehicles/available` - Get available vehicles

### Routes
- `POST /api/routes` - Create a new route
- `GET /api/routes` - Get all routes
- `GET /api/routes/{id}` - Get route by ID
- `PUT /api/routes/{id}` - Update a route
- `DELETE /api/routes/{id}` - Delete a route
- `POST /api/routes/generate` - Generate optimized route
- `PATCH /api/routes/{id}/status?status=IN_PROGRESS` - Update route status

## Example Requests

### Create a Collection Point
```bash
curl -X POST http://localhost:8080/api/points \
  -H "Content-Type: application/json" \
  -d '{
    "location": {
      "latitude": 48.8566,
      "longitude": 2.3522,
      "address": "123 Rue de Paris"
    },
    "wasteType": "PLASTIC",
    "fillLevel": 95,
    "status": "ACTIVE",
    "lastEmptied": "2023-10-27T10:00:00"
  }'
```

### Generate Optimized Route
```bash
curl -X POST http://localhost:8080/api/routes/generate
```

## Key Features

### 1. Alert System
- Automatically detects containers with fill level ≥ 90%
- Returns alerts via `/api/points/alerts`

### 2. Route Optimization
- Generates routes based on container fill levels
- Prioritizes containers >80% full
- Assigns available vehicles and employees
- Sorts by fill level (highest first)

### 3. Auto-Assignment
- Employees can be auto-assigned to zones with most full containers
- Uses simple zone extraction from addresses

### 4. Logging
- All important operations are logged
- Logs stored in `logs/waste-management.log`
- Console and file output

## MongoDB Collections

### collection_points
```json
{
  "_id": "ObjectId",
  "location": { "latitude": 48.8566, "longitude": 2.3522, "address": "..." },
  "wasteType": "PLASTIC",
  "fillLevel": 95,
  "status": "ACTIVE",
  "lastEmptied": "2023-10-27T10:00:00Z"
}
```

### employees
```json
{
  "_id": "ObjectId",
  "name": "Jean Dupont",
  "role": "DRIVER",
  "zone": "ZONE_NORTH",
  "available": true,
  "competencies": ["GLASS", "PLASTIC"]
}
```

### vehicles
```json
{
  "_id": "ObjectId",
  "plateNumber": "AB-123-CD",
  "capacity": 1000,
  "status": "AVAILABLE",
  "currentLocation": { "latitude": ..., "longitude": ... }
}
```

### routes
```json
{
  "_id": "ObjectId",
  "status": "PLANNED",
  "date": "2023-10-28",
  "vehicleId": "...",
  "employeeIds": ["..."],
  "pointsToCollect": [
    { "pointId": "...", "priority": "HIGH" }
  ],
  "estimatedDistanceKm": 15.5
}
```

## Testing
The project includes JUnit tests for:
- Alert detection logic
- Route generation algorithm
- Service layer methods

Run tests with: `mvn test`
