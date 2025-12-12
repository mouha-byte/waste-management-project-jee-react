# 🗑️ Smart Urban Waste Management System

A complete full-stack application for optimizing urban waste collection routes and managing collection points in real-time.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Screenshots](#screenshots)
- [Testing](#testing)

## 🎯 Overview

This system helps municipalities optimize waste collection by:
- **Real-time Monitoring**: Track container fill levels
- **Smart Routing**: Generate optimized collection routes based on fill levels
- **Alert System**: Automatic notifications when containers reach 90% capacity
- **Resource Management**: Manage employees, vehicles, and collection points
- **Analytics Dashboard**: Visual insights into collection operations

## ✨ Features

### Backend (Spring Boot)
- ✅ RESTful API with layered architecture (Controller → Service → Repository)
- ✅ MongoDB NoSQL database integration
- ✅ Automatic route optimization algorithm
- ✅ Alert detection system (containers ≥90% full)
- ✅ Employee auto-assignment to zones
- ✅ Comprehensive logging with Log4j2
- ✅ Unit tests with JUnit 5

### Frontend (React)
- ✅ Modern, responsive UI with gradient design
- ✅ Real-time dashboard with statistics
- ✅ Collection points CRUD operations
- ✅ Visual fill level indicators
- ✅ Alert notifications
- ✅ One-click route generation

## 🛠️ Technology Stack

### Backend
- **Framework**: Spring Boot 3.2.0
- **Database**: MongoDB
- **Build Tool**: Maven
- **Logging**: Log4j2
- **Testing**: JUnit 5, Mockito
- **Language**: Java 17

### Frontend
- **Framework**: React 18
- **Build Tool**: Vite
- **Styling**: Vanilla CSS
- **HTTP Client**: Fetch API
- **Language**: JavaScript (ES6+)

## 🏗️ Architecture

### Backend Layers
```
┌─────────────────────────────────┐
│      Controllers (REST API)      │
├─────────────────────────────────┤
│      Services (Business Logic)   │
├─────────────────────────────────┤
│   Repositories (Data Access)     │
├─────────────────────────────────┤
│      MongoDB (NoSQL Database)    │
└─────────────────────────────────┘
```

### Project Structure
```
projet/
├── backend/                    # Spring Boot backend
│   ├── src/main/java/com/waste/
│   │   ├── config/            # CORS, configurations
│   │   ├── controller/        # REST controllers
│   │   ├── dto/               # Data transfer objects
│   │   ├── model/             # Domain entities
│   │   ├── repository/        # MongoDB repositories
│   │   ├── service/           # Business logic
│   │   └── WasteManagementApplication.java
│   ├── src/test/              # Unit tests
│   ├── pom.xml
│   └── README.md
│
├── frontend/                   # React frontend
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── services/          # API service layer
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── package.json
│   ├── vite.config.js
│   └── README.md
│
└── README.md                   # This file
```

## 🚀 Getting Started

### Prerequisites
- Java 17+
- Maven 3.6+
- Node.js 16+
- MongoDB 4.4+

### 1. Start MongoDB
```bash
# Windows (if installed as service)
net start MongoDB

# Or use Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### 2. Start Backend
```bash
cd backend
mvn clean install
mvn spring-boot:run
```
Backend will run on `http://localhost:8080`

### 3. Start Frontend
```bash
cd frontend
npm install
npm run dev
```
Frontend will run on `http://localhost:5174`

### 4. Access the Application
Open your browser and navigate to `http://localhost:5174`

## 📡 API Documentation

### Collection Points
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/points` | Get all collection points |
| GET | `/api/points/{id}` | Get point by ID |
| POST | `/api/points` | Create new point |
| PUT | `/api/points/{id}` | Update point |
| DELETE | `/api/points/{id}` | Delete point |
| GET | `/api/points/alerts` | Get alerts (≥90% full) |
| GET | `/api/points/needing-collection` | Get points ≥80% full |

### Routes
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/routes` | Get all routes |
| POST | `/api/routes/generate` | Generate optimized route |
| PATCH | `/api/routes/{id}/status` | Update route status |

### Employees
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/employees` | Get all employees |
| POST | `/api/employees` | Create employee |
| POST | `/api/employees/{id}/auto-assign-zone` | Auto-assign to zone |

### Vehicles
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/vehicles` | Get all vehicles |
| POST | `/api/vehicles` | Create vehicle |
| GET | `/api/vehicles/available` | Get available vehicles |

## 🗄️ Database Schema (MongoDB)

### CollectionPoint
```json
{
  "_id": "ObjectId",
  "location": {
    "latitude": 48.8566,
    "longitude": 2.3522,
    "address": "123 Rue de Paris"
  },
  "wasteType": "PLASTIC",
  "fillLevel": 95,
  "status": "ACTIVE",
  "lastEmptied": "2023-10-27T10:00:00Z"
}
```

### Employee
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

### Vehicle
```json
{
  "_id": "ObjectId",
  "plateNumber": "AB-123-CD",
  "capacity": 1000,
  "status": "AVAILABLE",
  "currentLocation": { "latitude": 48.8566, "longitude": 2.3522 }
}
```

### Route
```json
{
  "_id": "ObjectId",
  "status": "PLANNED",
  "date": "2023-10-28",
  "vehicleId": "ObjectId",
  "employeeIds": ["ObjectId1", "ObjectId2"],
  "pointsToCollect": [
    { "pointId": "ObjectId", "priority": "HIGH" }
  ],
  "estimatedDistanceKm": 15.5
}
```

## 🧪 Testing

### Run Backend Tests
```bash
cd backend
mvn test
```

Tests include:
- ✅ Alert detection logic (fillLevel ≥ 90%)
- ✅ Route generation algorithm
- ✅ Service layer methods

### Manual Testing Scenario

**Scenario: Container Alert Flow**

1. **Start both backend and frontend**
2. **Add a container with 50% fill level**
   - Go to "Collection Points"
   - Click "Add New Point"
   - Fill form with fillLevel = 50
   - Save
3. **Update container to 95% fill level**
   - Click "Edit" on the container
   - Change fillLevel to 95
   - Notice the warning: "⚠️ Warning: This container will trigger an alert!"
   - Save
4. **Verify alert appears**
   - Go to "Dashboard"
   - See the container in "🚨 Active Alerts" section (red background)
   - Container is highlighted in the points table
5. **Generate a route**
   - Click "🚛 Generate Route" button
   - Route is created with this container included
   - See new route in "Recent Routes" table

## 📊 Key Algorithms

### Route Optimization
```java
// Simple but effective algorithm:
1. Get all containers with fillLevel ≥ 80%
2. Sort by fillLevel (highest first)
3. Assign priority:
   - HIGH: fillLevel ≥ 95%
   - MEDIUM: fillLevel ≥ 85%
   - LOW: fillLevel ≥ 80%
4. Select vehicle with highest capacity
5. Assign available employees (max 2 per route)
6. Estimate distance: points × 2.5 km
```

### Auto-Assignment
```java
// Assign employee to zone with most full containers:
1. Get all containers needing collection
2. Group by zone (extracted from address)
3. Count containers per zone
4. Assign employee to zone with highest count
```

## 🎨 UI Features

- **Color-coded Fill Levels**:
  - 🟢 Green: 0-69% (Low)
  - 🟠 Orange: 70-89% (Medium)
  - 🔴 Red: 90-100% (High/Alert)

- **Status Badges**:
  - 🟢 Active
  - 🟠 Maintenance
  - 🔴 Broken

- **Responsive Design**: Works on desktop, tablet, and mobile

## 📝 Logs

Backend logs are stored in `backend/logs/waste-management.log`

Example log entries:
```
2023-10-28 14:30:15 - Creating new collection point at 123 Rue de Paris
2023-10-28 14:30:20 - Collection point abc123 needs attention - fill level: 95%
2023-10-28 14:35:10 - Route generated: 4 points, vehicle AB-123-CD, estimated distance: 10.0 km
```

## 🔐 Security Notes

- CORS is configured to allow frontend (localhost:5174) to access backend
- For production, implement proper authentication (Spring Security)
- Use environment variables for sensitive configuration

## 🚧 Future Enhancements

- [ ] Real-time WebSocket updates
- [ ] Interactive map with Google Maps API
- [ ] Mobile app (React Native)
- [ ] Advanced routing with Google Directions API
- [ ] IoT sensor integration
- [ ] Predictive analytics with ML
- [ ] Multi-language support
- [ ] Export reports (PDF, Excel)

## 📄 License

This project is for educational purposes.

## 👥 Contributors

Developed as a demonstration of full-stack development with Spring Boot and React.

---

**Made with ❤️ using Spring Boot + React + MongoDB**