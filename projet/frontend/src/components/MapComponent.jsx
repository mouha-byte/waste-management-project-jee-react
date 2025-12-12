import React, { useEffect, useState, useRef } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';
import { collectionPointsAPI } from '../services/api';
import L from 'leaflet';
import 'leaflet-routing-machine';

// Fix for default marker icon in React Leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// Custom icons for different fill levels
const getIcon = (fillLevel) => {
    let color = 'green';
    if (fillLevel >= 90) color = 'red';
    else if (fillLevel >= 50) color = 'orange';

    return new L.DivIcon({
        className: 'custom-marker',
        html: `<div style="background-color: ${color}; width: 20px; height: 20px; border-radius: 50%; border: 2px solid white; box-shadow: 0 0 5px rgba(0,0,0,0.5);"></div>`,
        iconSize: [20, 20],
        iconAnchor: [10, 10],
        popupAnchor: [0, -10]
    });
};

// Depot icon (warehouse/home)
const depotIcon = new L.DivIcon({
    className: 'depot-marker',
    html: `<div style="background-color: #4299e1; width: 30px; height: 30px; border-radius: 4px; border: 3px solid white; box-shadow: 0 0 8px rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; font-size: 18px;">🏭</div>`,
    iconSize: [30, 30],
    iconAnchor: [15, 15],
    popupAnchor: [0, -15]
});

// Route point icon (numbered)
const getRoutePointIcon = (index) => {
    return new L.DivIcon({
        className: 'route-point-marker',
        html: `<div style="background-color: #805ad5; width: 26px; height: 26px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 6px rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px;">${index + 1}</div>`,
        iconSize: [26, 26],
        iconAnchor: [13, 13],
        popupAnchor: [0, -13]
    });
};

// Component to handle routing
function RoutingMachine({ routes, points }) {
    const map = useMap();
    const routingControlRef = useRef(null);

    useEffect(() => {
        if (!map || routes.length === 0) return;

        // Clear existing routing control
        if (routingControlRef.current) {
            map.removeControl(routingControlRef.current);
            routingControlRef.current = null;
        }

        // Get the first route (or you can handle multiple routes)
        const route = routes[0];
        if (!route.depotLocation || !route.pointsToCollect) return;

        // Build waypoints
        const waypoints = [];

        // Start at depot
        waypoints.push(L.latLng(route.depotLocation.latitude, route.depotLocation.longitude));

        // Add each collection point
        route.pointsToCollect.forEach(routePoint => {
            const point = points.find(p => p.id === routePoint.pointId);
            if (point && point.location) {
                waypoints.push(L.latLng(point.location.latitude, point.location.longitude));
            }
        });

        // Return to depot
        waypoints.push(L.latLng(route.depotLocation.latitude, route.depotLocation.longitude));

        // Create routing control
        const routingControl = L.Routing.control({
            waypoints: waypoints,
            routeWhileDragging: false,
            addWaypoints: false,
            draggableWaypoints: false,
            fitSelectedRoutes: true,
            showAlternatives: false,
            lineOptions: {
                styles: [{
                    color: route.status === 'IN_PROGRESS' ? '#48bb78' :
                        route.status === 'COMPLETED' ? '#718096' : '#4299e1',
                    opacity: 0.7,
                    weight: 5
                }]
            },
            createMarker: function () { return null; }, // Don't create default markers
            router: L.Routing.osrmv1({
                serviceUrl: 'https://router.project-osrm.org/route/v1'
            })
        }).addTo(map);

        routingControlRef.current = routingControl;

        // Hide the routing instructions panel
        const container = routingControl.getContainer();
        if (container) {
            container.style.display = 'none';
        }

        return () => {
            if (routingControlRef.current) {
                map.removeControl(routingControlRef.current);
            }
        };
    }, [map, routes, points]);

    return null;
}

function MapComponent({ height = '600px', routes = [] }) {
    const [points, setPoints] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    // Default center (Tunis)
    const defaultCenter = [36.8065, 10.1815];

    useEffect(() => {
        loadPoints();
    }, []);

    const loadPoints = async () => {
        try {
            setLoading(true);
            const data = await collectionPointsAPI.getAll();
            setPoints(data);
        } catch (err) {
            setError('Failed to load points for map: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="loading"><div className="spinner"></div></div>;
    if (error) return <div className="alert-box error">{error}</div>;

    return (
        <div style={{ height: height, width: '100%', borderRadius: '12px', overflow: 'hidden', boxShadow: '0 4px 6px rgba(0,0,0,0.1)' }}>
            <MapContainer center={defaultCenter} zoom={13} style={{ height: '100%', width: '100%' }}>
                <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />

                {/* Add routing machine for routes */}
                {routes.length > 0 && <RoutingMachine routes={routes} points={points} />}

                {/* Depot markers */}
                {routes.map(route => {
                    if (!route.depotLocation) return null;
                    return (
                        <Marker
                            key={`depot-${route.id}`}
                            position={[route.depotLocation.latitude, route.depotLocation.longitude]}
                            icon={depotIcon}
                        >
                            <Popup>
                                <div style={{ minWidth: '150px' }}>
                                    <h3 style={{ margin: '0 0 5px 0', fontSize: '16px' }}>🏭 Depot</h3>
                                    <p style={{ margin: '5px 0', fontSize: '14px' }}>{route.depotLocation.address}</p>
                                    <p style={{ fontSize: '12px', color: '#718096', marginTop: '5px' }}>
                                        Route Status: <strong>{route.status}</strong>
                                    </p>
                                </div>
                            </Popup>
                        </Marker>
                    );
                })}

                {/* Route point markers (numbered) */}
                {routes.map(route => {
                    if (!route.pointsToCollect) return null;
                    return route.pointsToCollect.map((routePoint, index) => {
                        const point = points.find(p => p.id === routePoint.pointId);
                        if (!point || !point.location) return null;

                        return (
                            <Marker
                                key={`route-${route.id}-point-${routePoint.pointId}`}
                                position={[point.location.latitude, point.location.longitude]}
                                icon={getRoutePointIcon(index)}
                            >
                                <Popup>
                                    <div style={{ minWidth: '150px' }}>
                                        <h3 style={{ margin: '0 0 5px 0', fontSize: '16px' }}>
                                            Stop #{index + 1} - {point.wasteType}
                                        </h3>
                                        <p style={{ margin: '5px 0', fontSize: '14px' }}>📍 {point.location.address}</p>
                                        <div style={{
                                            marginTop: '10px',
                                            padding: '5px',
                                            borderRadius: '4px',
                                            background: point.fillLevel >= 90 ? '#fed7d7' : '#f0fff4',
                                            color: point.fillLevel >= 90 ? '#c53030' : '#2f855a',
                                            fontWeight: 'bold',
                                            textAlign: 'center'
                                        }}>
                                            Fill Level: {point.fillLevel}%
                                        </div>
                                        <p style={{ fontSize: '12px', color: '#718096', marginTop: '5px' }}>
                                            Priority: <strong>{routePoint.priority}</strong>
                                        </p>
                                    </div>
                                </Popup>
                            </Marker>
                        );
                    });
                })}

                {/* Regular collection points (not in routes) */}
                {points.map(point => {
                    // Check if this point is in any route
                    const isInRoute = routes.some(route =>
                        route.pointsToCollect?.some(rp => rp.pointId === point.id)
                    );

                    if (isInRoute || !point.location) return null;

                    return (
                        <Marker
                            key={point.id}
                            position={[point.location.latitude, point.location.longitude]}
                            icon={getIcon(point.fillLevel)}
                        >
                            <Popup>
                                <div style={{ minWidth: '150px' }}>
                                    <h3 style={{ margin: '0 0 5px 0', fontSize: '16px' }}>{point.wasteType} Container</h3>
                                    <p style={{ margin: '5px 0', fontSize: '14px' }}>📍 {point.location.address}</p>
                                    <div style={{
                                        marginTop: '10px',
                                        padding: '5px',
                                        borderRadius: '4px',
                                        background: point.fillLevel >= 90 ? '#fed7d7' : '#f0fff4',
                                        color: point.fillLevel >= 90 ? '#c53030' : '#2f855a',
                                        fontWeight: 'bold',
                                        textAlign: 'center'
                                    }}>
                                        Fill Level: {point.fillLevel}%
                                    </div>
                                    <p style={{ fontSize: '12px', color: '#718096', marginTop: '5px' }}>
                                        Status: {point.status}
                                    </p>
                                </div>
                            </Popup>
                        </Marker>
                    );
                })}
            </MapContainer>
        </div>
    );
}

export default MapComponent;
