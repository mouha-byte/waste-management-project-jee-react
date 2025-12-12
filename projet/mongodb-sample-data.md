# MongoDB Sample Data Script

# This script provides sample data for testing the Waste Management System

## Sample Collection Points

```javascript
// Connect to MongoDB
use waste_management;

// Insert sample collection points
db.collection_points.insertMany([
  {
    location: {
      latitude: 48.8566,
      longitude: 2.3522,
      address: "123 Rue de Paris North"
    },
    wasteType: "PLASTIC",
    fillLevel: 95,
    status: "ACTIVE",
    lastEmptied: new Date("2023-10-20T10:00:00Z")
  },
  {
    location: {
      latitude: 48.8606,
      longitude: 2.3376,
      address: "456 Avenue des Champs South"
    },
    wasteType: "GLASS",
    fillLevel: 85,
    status: "ACTIVE",
    lastEmptied: new Date("2023-10-22T14:00:00Z")
  },
  {
    location: {
      latitude: 48.8529,
      longitude: 2.3499,
      address: "789 Boulevard Saint-Germain East"
    },
    wasteType: "ORGANIC",
    fillLevel: 92,
    status: "ACTIVE",
    lastEmptied: new Date("2023-10-21T09:00:00Z")
  },
  {
    location: {
      latitude: 48.8738,
      longitude: 2.2950,
      address: "321 Rue de la République West"
    },
    wasteType: "GENERAL",
    fillLevel: 50,
    status: "ACTIVE",
    lastEmptied: new Date("2023-10-27T11:00:00Z")
  },
  {
    location: {
      latitude: 48.8584,
      longitude: 2.2945,
      address: "654 Place de la Concorde Central"
    },
    wasteType: "PLASTIC",
    fillLevel: 30,
    status: "ACTIVE",
    lastEmptied: new Date("2023-10-26T15:00:00Z")
  },
  {
    location: {
      latitude: 48.8467,
      longitude: 2.3514,
      address: "987 Rue Mouffetard South"
    },
    wasteType: "GLASS",
    fillLevel: 78,
    status: "MAINTENANCE",
    lastEmptied: new Date("2023-10-23T13:00:00Z")
  }
]);

// Insert sample employees
db.employees.insertMany([
  {
    name: "Jean Dupont",
    role: "DRIVER",
    zone: "ZONE_NORTH",
    available: true,
    competencies: ["PLASTIC", "GLASS", "GENERAL"]
  },
  {
    name: "Marie Martin",
    role: "COLLECTOR",
    zone: "ZONE_SOUTH",
    available: true,
    competencies: ["ORGANIC", "GENERAL"]
  },
  {
    name: "Pierre Durand",
    role: "DRIVER",
    zone: "ZONE_EAST",
    available: false,
    competencies: ["PLASTIC", "GLASS"]
  },
  {
    name: "Sophie Bernard",
    role: "COLLECTOR",
    zone: "ZONE_CENTRAL",
    available: true,
    competencies: ["PLASTIC", "GLASS", "ORGANIC", "GENERAL"]
  }
]);

// Insert sample vehicles
db.vehicles.insertMany([
  {
    plateNumber: "AB-123-CD",
    capacity: 1000,
    status: "AVAILABLE",
    currentLocation: {
      latitude: 48.8566,
      longitude: 2.3522
    }
  },
  {
    plateNumber: "EF-456-GH",
    capacity: 1500,
    status: "AVAILABLE",
    currentLocation: {
      latitude: 48.8606,
      longitude: 2.3376
    }
  },
  {
    plateNumber: "IJ-789-KL",
    capacity: 800,
    status: "MAINTENANCE",
    currentLocation: {
      latitude: 48.8529,
      longitude: 2.3499
    }
  }
]);

console.log("Sample data inserted successfully!");
console.log("Collection Points:", db.collection_points.count());
console.log("Employees:", db.employees.count());
console.log("Vehicles:", db.vehicles.count());
```

## How to Use

### Option 1: MongoDB Shell
```bash
# Connect to MongoDB
mongosh

# Run the script
use waste_management;
# Copy and paste the insertMany commands above
```

### Option 2: MongoDB Compass
1. Open MongoDB Compass
2. Connect to `mongodb://localhost:27017`
3. Create database `waste_management`
4. Create collections: `collection_points`, `employees`, `vehicles`
5. Use "Add Data" → "Import JSON" to import the documents

### Option 3: Using the API
You can also use the REST API to create sample data:

```bash
# Create a collection point
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

## Verification

After inserting data, verify in MongoDB:

```javascript
// Count documents
db.collection_points.count()  // Should return 6
db.employees.count()          // Should return 4
db.vehicles.count()           // Should return 3

// Find containers that need collection (>80% full)
db.collection_points.find({ fillLevel: { $gte: 80 } })

// Find available employees
db.employees.find({ available: true })

// Find available vehicles
db.vehicles.find({ status: "AVAILABLE" })
```

## Expected Results

After inserting this data:
- **3 containers** will trigger alerts (fillLevel ≥ 90%): 95%, 92%, 85%
- **2 containers** will be included in route generation (≥ 80%)
- **3 available employees** can be assigned to routes
- **2 available vehicles** can be used for collection

This data is perfect for testing the route generation feature!
