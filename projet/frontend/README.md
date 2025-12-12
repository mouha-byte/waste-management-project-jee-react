# Waste Management System - Frontend

## Overview
React frontend for the Smart Urban Waste Management System.

## Technologies
- **Framework**: React 18
- **Build Tool**: Vite
- **Styling**: Vanilla CSS
- **HTTP Client**: Fetch API

## Prerequisites
- Node.js 16+
- npm or yarn

## Project Structure
```
frontend/
├── src/
│   ├── components/
│   │   ├── Dashboard.jsx       # Main dashboard with stats and alerts
│   │   ├── PointsList.jsx      # Collection points list view
│   │   └── PointForm.jsx       # Add/Edit form for points
│   ├── services/
│   │   └── api.js              # API service layer
│   ├── App.jsx                 # Main app component
│   ├── main.jsx                # React entry point
│   └── index.css               # Global styles
├── index.html
├── vite.config.js
└── package.json
```

## Setup & Run

### 1. Install dependencies
```bash
cd frontend
npm install
```

### 2. Start development server
```bash
npm run dev
```

The app will be available at `http://localhost:5174`

### 3. Build for production
```bash
npm run build
```

## Features

### Dashboard
- **Statistics Cards**: Total points, active points, alerts, average fill level
- **Active Alerts**: Real-time display of containers ≥90% full
- **Route Generation**: One-click button to generate optimized collection routes
- **Recent Routes**: Table showing last 5 generated routes
- **All Points Overview**: Complete list with visual fill level indicators

### Collection Points Management
- **List View**: Table with all collection points
- **Visual Indicators**: 
  - Color-coded fill level bars (green/orange/red)
  - Status badges (Active/Maintenance/Broken)
  - Alert badges for urgent containers
- **CRUD Operations**: Create, Read, Update, Delete
- **Real-time Updates**: List refreshes after add/edit/delete

### Add/Edit Form
- **Validation**: Required fields and range validation
- **Visual Feedback**: Live fill level preview
- **Alert Warning**: Shows warning if fill level ≥90%
- **Location Support**: Address, latitude, longitude
- **Waste Type Selection**: Plastic, Glass, Organic, General
- **Status Management**: Active, Maintenance, Broken

## API Integration

The frontend connects to the backend API at `http://localhost:8080/api`

Endpoints used:
- `GET /points` - Fetch all collection points
- `POST /points` - Create new point
- `PUT /points/{id}` - Update point
- `DELETE /points/{id}` - Delete point
- `GET /points/alerts` - Get alerts
- `POST /routes/generate` - Generate optimized route
- `GET /routes` - Fetch all routes

## Styling

The app uses a modern, clean design with:
- **Color Scheme**: Purple gradient background (#667eea to #764ba2)
- **Components**: Card-based layout with shadows
- **Responsive**: Works on desktop and mobile
- **Animations**: Smooth transitions and hover effects
- **Visual Feedback**: Color-coded alerts and status indicators

## User Flow

### Scenario 1: Add a new container
1. Click "Collection Points" in navigation
2. Click "+ Add New Point" button
3. Fill in the form (address, waste type, fill level, etc.)
4. Click "Create"
5. List automatically updates with new point

### Scenario 2: Container reaches 90% full
1. Edit a container and set fill level to 95%
2. Form shows warning: "⚠️ Warning: This container will trigger an alert!"
3. Save the container
4. Go to Dashboard
5. See the alert in red: "🚨 Active Alerts" section
6. Container is highlighted in the points table

### Scenario 3: Generate collection route
1. Add several containers with fill levels >80%
2. Go to Dashboard
3. Click "🚛 Generate Route" button
4. Backend creates optimized route
5. New route appears in "Recent Routes" table

## Development Notes

- The app uses React hooks (useState, useEffect) for state management
- No external UI libraries - all components are custom
- API calls are centralized in `src/services/api.js`
- Error handling is implemented for all API calls
- Loading states are shown during async operations

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
