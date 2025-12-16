import React, { useState, useEffect } from 'react';
import { collectionPointsAPI, routesAPI, incidentsAPI } from '../services/api';
import MapComponent from './MapComponent';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';

function Dashboard() {
    const [alerts, setAlerts] = useState([]);
    const [points, setPoints] = useState([]);
    const [routes, setRoutes] = useState([]);
    const [incidents, setIncidents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [generating, setGenerating] = useState(false);
    const [showAllActiveRoutes, setShowAllActiveRoutes] = useState(false);

    useEffect(() => {
        loadDashboardData();
    }, []);

    const loadDashboardData = async () => {
        try {
            setLoading(true);
            const [alertsData, pointsData, routesData, incidentsData] = await Promise.all([
                collectionPointsAPI.getAlerts(),
                collectionPointsAPI.getAll(),
                routesAPI.getAll(),
                incidentsAPI.getAll()
            ]);

            setAlerts(alertsData);
            setPoints(pointsData);
            setRoutes(routesData);
            setIncidents(incidentsData);
            setError(null);
        } catch (err) {
            setError('Failed to load dashboard data: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const handleGenerateRoute = async () => {
        try {
            setGenerating(true);
            setError(null);
            await routesAPI.generateOptimized();
            await loadDashboardData(); // Reload to show new route
            alert('Route generated successfully!');
        } catch (err) {
            setError('Failed to generate route: ' + err.message);
        } finally {
            setGenerating(false);
        }
    };

    const generatePDF = () => {
        const doc = new jsPDF();
        const stats = calculateStats();

        // Title
        doc.setFontSize(20);
        doc.setTextColor(44, 82, 130);
        doc.text('Smart Waste Management - System Report', 14, 22);

        doc.setFontSize(10);
        doc.setTextColor(100);
        doc.text(`Generated on: ${new Date().toLocaleString()}`, 14, 30);

        // Stats Section
        doc.setFontSize(14);
        doc.setTextColor(0);
        doc.text('System Overview', 14, 45);

        const statsData = [
            ['Total Collection Points', stats.totalPoints],
            ['Active Points', stats.activePoints],
            ['Critical Alerts', stats.alertPoints],
            ['Average Fill Level', `${stats.avgFillLevel}%`],
            ['Total Waste Collected (Est.)', `${stats.totalWaste} kg`],
            ['CO2 Emission Saved', `${stats.co2Saved} kg`]
        ];

        autoTable(doc, {
            startY: 50,
            head: [['Metric', 'Value']],
            body: statsData,
            theme: 'striped',
            headStyles: { fillColor: [44, 82, 130] }
        });

        // Alerts Section
        if (alerts.length > 0) {
            const finalY = doc.lastAutoTable.finalY || 50;
            doc.text('Active Alerts', 14, finalY + 15);

            autoTable(doc, {
                startY: finalY + 20,
                head: [['Priority', 'Point ID', 'Fill Level', 'Message']],
                body: alerts.map(a => [a.priority, a.pointId, `${a.fillLevel}%`, a.message]),
                theme: 'grid',
                headStyles: { fillColor: [197, 48, 48] }
            });
        }

        // Recent Routes
        const finalY = doc.lastAutoTable.finalY || 50;
        doc.text('Recent Routes', 14, finalY + 15);

        autoTable(doc, {
            startY: finalY + 20,
            head: [['Date', 'Status', 'Vehicle', 'Distance (km)']],
            body: routes.slice(0, 10).map(r => [
                new Date(r.date).toLocaleDateString(),
                r.status,
                r.vehicleId || 'N/A',
                r.estimatedDistanceKm?.toFixed(1)
            ]),
            theme: 'striped'
        });

        // Incidents Section
        if (incidents.length > 0) {
            const finalY = doc.lastAutoTable.finalY || 50;
            doc.text('Reported Incidents', 14, finalY + 15);

            autoTable(doc, {
                startY: finalY + 20,
                head: [['Date', 'Type', 'Description']],
                body: incidents.map(i => [
                    new Date(i.date).toLocaleDateString(),
                    i.type,
                    i.description
                ]),
                theme: 'grid',
                headStyles: { fillColor: [237, 137, 54] } // Orange
            });
        }

        doc.save('waste-management-report.pdf');
    };

    const calculateStats = () => {
        const totalPoints = points.length;
        const activePoints = points.filter(p => p.status === 'ACTIVE').length;
        const alertPoints = points.filter(p => p.fillLevel >= 90).length;
        const avgFillLevel = points.length > 0
            ? Math.round(points.reduce((sum, p) => sum + p.fillLevel, 0) / points.length)
            : 0;

        // Mock environmental stats based on data
        const totalWaste = points.reduce((sum, p) => sum + (p.fillLevel * 10), 0); // Mock: 10kg per 1%
        const co2Saved = Math.round(totalWaste * 0.5); // Mock: 0.5kg CO2 per kg waste recycled

        return { totalPoints, activePoints, alertPoints, avgFillLevel, totalWaste, co2Saved };
    };

    if (loading) {
        return (
            <div className="loading">
                <div className="spinner"></div>
            </div>
        );
    }

    const stats = calculateStats();

    const activeRoutes = routes.filter(r => r.status === 'IN_PROGRESS');
    const visibleActiveRoutes = showAllActiveRoutes ? activeRoutes : activeRoutes.slice(0, 5);

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2>Dashboard</h2>
                <div style={{ display: 'flex', gap: '10px' }}>
                    <button
                        className="btn btn-secondary"
                        onClick={generatePDF}
                        style={{ display: 'flex', alignItems: 'center', gap: '5px' }}
                    >
                        📄 Download Report
                    </button>
                    <button
                        className="btn btn-success"
                        onClick={handleGenerateRoute}
                        disabled={generating}
                    >
                        {generating ? 'Generating...' : '🚛 Generate Route'}
                    </button>
                </div>
            </div>

            {error && (
                <div className="alert-box error">
                    {error}
                </div>
            )}

            {/* Statistics Cards */}
            <div className="dashboard-grid">
                <div className="dashboard-card">
                    <h3>Total Points</h3>
                    <div className="stat-value">{stats.totalPoints}</div>
                    <div className="stat-label">Collection points</div>
                </div>

                <div className="dashboard-card">
                    <h3>Active Points</h3>
                    <div className="stat-value">{stats.activePoints}</div>
                    <div className="stat-label">Currently operational</div>
                </div>

                <div className="dashboard-card" style={{ borderLeftColor: '#f56565' }}>
                    <h3>Alerts</h3>
                    <div className="stat-value" style={{ color: '#f56565' }}>{stats.alertPoints}</div>
                    <div className="stat-label">Containers ≥90% full</div>
                </div>

                <div className="dashboard-card" style={{ borderLeftColor: '#38a169' }}>
                    <h3>Eco Impact</h3>
                    <div className="stat-value" style={{ color: '#38a169', fontSize: '1.8rem' }}>{stats.co2Saved} kg</div>
                    <div className="stat-label">CO2 Emissions Saved</div>
                </div>

                <div className="dashboard-card">
                    <h3>Avg Fill Level</h3>
                    <div className="stat-value">{stats.avgFillLevel}%</div>
                    <div className="stat-label">Across all containers</div>
                </div>
            </div>



            {/* Main Content Grid: Map + Alerts/Routes */}
            <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: '25px', marginTop: '30px', marginBottom: '30px' }}>

                {/* Left Column: Map */}
                <div>
                    <h3 style={{ marginBottom: '15px' }}>🌍 Live Overview</h3>
                    <MapComponent height="400px" routes={routes} />
                </div>

                {/* Right Column: Alerts & Active Routes */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>

                    {/* Active Routes */}
                    {/* Active Routes */}
                    {activeRoutes.length > 0 && (
                        <div>
                            <h3 style={{ marginBottom: '15px', color: '#3182ce' }}>🚀 Active Routes</h3>
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                {visibleActiveRoutes.map(route => (
                                    <div key={route.id} className="dashboard-card" style={{ borderLeftColor: '#3182ce', margin: 0 }}>
                                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                            <h4 style={{ margin: 0 }}>Route #{route.id.slice(-6)}</h4>
                                            <span className="status-badge in_progress" style={{ fontSize: '0.75rem' }}>IN PROGRESS</span>
                                        </div>
                                        <div style={{ fontSize: '0.9rem', marginTop: '10px', color: '#4a5568' }}>
                                            <p style={{ margin: '5px 0' }}>🚛 {route.vehicleId || 'Assigned'}</p>
                                            <p style={{ margin: '5px 0' }}>📍 {route.pointsToCollect?.length || 0} points • {route.estimatedDistanceKm?.toFixed(1)} km</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                            {activeRoutes.length > 5 && (
                                <button
                                    onClick={() => setShowAllActiveRoutes(!showAllActiveRoutes)}
                                    style={{
                                        marginTop: '10px',
                                        width: '100%',
                                        padding: '8px',
                                        background: 'transparent',
                                        border: '1px solid #3182ce',
                                        color: '#3182ce',
                                        borderRadius: '6px',
                                        cursor: 'pointer',
                                        fontSize: '0.9rem'
                                    }}
                                >
                                    {showAllActiveRoutes ? 'Show Less' : `Show ${activeRoutes.length - 5} More`}
                                </button>
                            )}
                        </div>
                    )}

                    {/* Alerts */}
                    <div>
                        <h3 style={{ marginBottom: '15px', color: '#f56565' }}>
                            🚨 Active Alerts ({alerts.length})
                        </h3>
                        {alerts.length > 0 ? (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', maxHeight: '400px', overflowY: 'auto' }}>
                                {alerts.map((alert, index) => (
                                    <div
                                        key={index}
                                        className="alert-box error"
                                        style={{ fontSize: '14px', margin: 0, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}
                                    >
                                        <div>
                                            <span style={{ fontWeight: 'bold', display: 'block' }}>{alert.priority}</span>
                                            <span style={{ fontSize: '0.85rem' }}>{alert.message}</span>
                                        </div>
                                        <div style={{
                                            background: '#c53030',
                                            color: 'white',
                                            padding: '4px 8px',
                                            borderRadius: '12px',
                                            fontSize: '0.8rem',
                                            fontWeight: 'bold'
                                        }}>
                                            {alert.fillLevel}%
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <div style={{ padding: '20px', background: '#f0fff4', borderRadius: '8px', color: '#2f855a', textAlign: 'center' }}>
                                ✅ No active alerts. Great job!
                            </div>
                        )}

                        {/* Recent Incidents Section */}
                        <div style={{ marginTop: '30px' }}>
                            <h3 style={{ marginBottom: '15px', color: '#ed8936' }}>
                                ⚠️ Reported Incidents ({incidents.length})
                            </h3>
                            {incidents.length > 0 ? (
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', maxHeight: '300px', overflowY: 'auto' }}>
                                    {incidents.slice(0, 5).map((incident) => (
                                        <div key={incident.id} className="dashboard-card" style={{ borderLeftColor: '#ed8936', padding: '15px', margin: 0 }}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                                <strong>{incident.type}</strong>
                                                <small>{new Date(incident.date).toLocaleDateString()}</small>
                                            </div>
                                            <p style={{ margin: '5px 0', color: '#555', fontSize: '0.9em' }}>
                                                {incident.description}
                                            </p>
                                        </div>
                                    ))}
                                </div>
                            ) : (
                                <div style={{ padding: '20px', background: '#fffaf0', borderRadius: '8px', color: '#dd6b20', textAlign: 'center' }}>
                                    No reported incidents.
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            {/* Recent Routes */}
            {
                routes.length > 0 && (
                    <div style={{ marginTop: '30px' }}>
                        <h3 style={{ marginBottom: '15px' }}>📍 Recent Routes</h3>
                        <table className="table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Points</th>
                                    <th>Distance</th>
                                </tr>
                            </thead>
                            <tbody>
                                {routes.slice(0, 5).map((route) => (
                                    <tr key={route.id}>
                                        <td>{new Date(route.date).toLocaleDateString()}</td>
                                        <td>
                                            <span className={`status-badge ${route.status.toLowerCase()}`}>
                                                {route.status}
                                            </span>
                                        </td>
                                        <td>{route.pointsToCollect?.length || 0} points</td>
                                        <td>{route.estimatedDistanceKm?.toFixed(1) || 0} km</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )
            }

            {/* Points Map/Table */}
            <div style={{ marginTop: '30px' }}>
                <h3 style={{ marginBottom: '15px' }}>📊 All Collection Points</h3>
                <table className="table">
                    <thead>
                        <tr>
                            <th>Address</th>
                            <th>Type</th>
                            <th>Fill Level</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        {points.map((point) => (
                            <tr key={point.id} style={{ background: point.fillLevel >= 90 ? '#fed7d7' : 'transparent' }}>
                                <td>{point.location?.address || 'N/A'}</td>
                                <td>{point.wasteType}</td>
                                <td>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                        <div className="fill-level-bar">
                                            <div
                                                className={`fill-level-progress ${point.fillLevel >= 90 ? 'high' : point.fillLevel >= 70 ? 'medium' : 'low'
                                                    }`}
                                                style={{ width: `${point.fillLevel}%` }}
                                            ></div>
                                        </div>
                                        <span style={{ fontWeight: point.fillLevel >= 90 ? 'bold' : 'normal' }}>
                                            {point.fillLevel}%
                                        </span>
                                    </div>
                                </td>
                                <td>
                                    <span className={`status-badge ${point.status.toLowerCase()}`}>
                                        {point.status}
                                    </span>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div >
    );
}

export default Dashboard;
