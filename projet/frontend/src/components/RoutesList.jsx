import React, { useState, useEffect } from 'react';
import { routesAPI, incidentsAPI } from '../services/api';
import { useAuth } from '../context/AuthContext';
import MapComponent from './MapComponent';

function RoutesList() {
    const [routes, setRoutes] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [selectedRoute, setSelectedRoute] = useState(null); // For modal
    const [showIncidentModal, setShowIncidentModal] = useState(false);
    const [incidentForm, setIncidentForm] = useState({ type: 'BIN_DAMAGED', description: '' });
    const { user } = useAuth();

    useEffect(() => {
        loadRoutes();
    }, []);

    const loadRoutes = async () => {
        try {
            setLoading(true);
            const data = await routesAPI.getAll();
            setRoutes(data);
            setError(null);
        } catch (err) {
            setError('Failed to load routes: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this route?')) {
            return;
        }
        try {
            await routesAPI.delete(id);
            loadRoutes();
        } catch (err) {
            setError('Failed to delete route: ' + err.message);
        }
    };

    const handleStatusUpdate = async (id, newStatus) => {
        try {
            await routesAPI.updateStatus(id, newStatus);
            loadRoutes();
        } catch (err) {
            setError('Failed to update status: ' + err.message);
        }
    };

    if (loading) return <div className="loading"><div className="spinner"></div></div>;

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2>Routes Management</h2>
                <div>
                    <button className="btn btn-warning" style={{ marginRight: '10px' }} onClick={() => setShowIncidentModal(true)}>
                        ⚠️ Report Issue
                    </button>
                    {['ADMIN', 'MANAGER'].includes(user?.role) && (
                        <button className="btn btn-success" onClick={async () => {
                            try {
                                await routesAPI.generateOptimized();
                                loadRoutes();
                                alert('Route generated!');
                            } catch (e) { alert(e.message); }
                        }}>
                            🚛 Generate New Route
                        </button>
                    )}
                </div>
            </div>

            {error && <div className="alert-box error">{error}</div>}

            <table className="table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Vehicle</th>
                        <th>Points</th>
                        <th>Distance</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {routes.map(route => (
                        <tr key={route.id}>
                            <td>{new Date(route.date).toLocaleDateString()}</td>
                            <td>{route.vehicleId}</td>
                            <td>{route.pointsToCollect?.length || 0}</td>
                            <td>{route.estimatedDistanceKm?.toFixed(1)} km</td>
                            <td>
                                <span className={`status-badge ${route.status.toLowerCase()}`}>
                                    {route.status}
                                </span>
                            </td>
                            <td>
                                <div className="table-actions">
                                    <button
                                        className="btn btn-secondary"
                                        onClick={() => setSelectedRoute(route)}
                                        style={{ padding: '6px 12px', fontSize: '12px', marginRight: '5px' }}
                                    >
                                        👁️ Details
                                    </button>
                                    {route.status === 'PLANNED' && (
                                        <button className="btn btn-primary" onClick={() => handleStatusUpdate(route.id, 'IN_PROGRESS')} style={{ padding: '6px 12px', fontSize: '12px' }}>Start</button>
                                    )}
                                    {route.status === 'IN_PROGRESS' && (
                                        <button className="btn btn-success" onClick={() => handleStatusUpdate(route.id, 'COMPLETED')} style={{ padding: '6px 12px', fontSize: '12px' }}>Complete</button>
                                    )}
                                    {['ADMIN', 'MANAGER'].includes(user?.role) && (
                                        <button className="btn btn-danger" onClick={() => handleDelete(route.id)} style={{ padding: '6px 12px', fontSize: '12px' }}>Delete</button>
                                    )}
                                </div>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>

            {/* Route Details Modal */}
            {selectedRoute && (
                <div className="modal-overlay" onClick={() => setSelectedRoute(null)}>
                    <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '900px' }}>
                        <div className="modal-header">
                            <h3>Route Details #{selectedRoute.id.slice(-6)}</h3>
                            <button className="close-btn" onClick={() => setSelectedRoute(null)}>×</button>
                        </div>
                        <div className="modal-body">
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '20px' }}>
                                <div>
                                    <strong>Status:</strong> <span className={`status-badge ${selectedRoute.status.toLowerCase()}`}>{selectedRoute.status}</span>
                                </div>
                                <div>
                                    <strong>Date:</strong> {new Date(selectedRoute.date).toLocaleDateString()}
                                </div>
                                <div>
                                    <strong>Vehicle ID:</strong> {selectedRoute.vehicleId} <span style={{ fontSize: '0.9em', color: '#718096' }}> (Max: {selectedRoute.cachedVehicleCapacity || 'N/A'} kg)</span>
                                </div>
                                <div>
                                    <strong>Distance:</strong> {selectedRoute.estimatedDistanceKm?.toFixed(1)} km
                                </div>
                            </div>

                            <h4>👷 Assigned Employees</h4>
                            <ul style={{ marginBottom: '20px', paddingLeft: '20px' }}>
                                {selectedRoute.employeeIds?.map(empId => (
                                    <li key={empId}>{empId}</li>
                                ))}
                            </ul>

                            <h4>📍 Collection Points ({selectedRoute.pointsToCollect?.length})</h4>
                            <div style={{ maxHeight: '200px', overflowY: 'auto', border: '1px solid #e2e8f0', borderRadius: '4px' }}>
                                <table className="table" style={{ margin: 0 }}>
                                    <thead style={{ position: 'sticky', top: 0, background: 'white' }}>
                                        <tr>
                                            <th>Point ID</th>
                                            <th>Volume (kg)</th>
                                            <th>Priority</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {selectedRoute.pointsToCollect?.map((point, idx) => (
                                            <tr key={idx}>
                                                <td>{point.pointId}</td>
                                                <td>{point.cachedCapacity || '-'} kg</td>
                                                <td>
                                                    <span style={{
                                                        color: point.priority === 'HIGH' ? 'red' : point.priority === 'MEDIUM' ? 'orange' : 'green',
                                                        fontWeight: 'bold'
                                                    }}>
                                                        {point.priority}
                                                    </span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>

                            <h4 style={{ marginTop: '20px' }}>🗺️ Route Visualization</h4>
                            <div style={{ marginTop: '10px', border: '2px solid #e2e8f0', borderRadius: '8px', overflow: 'hidden' }}>
                                <MapComponent height="350px" routes={[selectedRoute]} />
                            </div>
                        </div>
                        <div className="modal-footer">
                            <button className="btn btn-secondary" onClick={() => setSelectedRoute(null)}>Close</button>
                        </div>
                    </div>
                </div>
            )}

            {/* Simple Modal Styles */}
            <style>{`
                .modal-overlay {
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: rgba(0, 0, 0, 0.5);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    z-index: 1000;
                }
                .modal-content {
                    background: white;
                    padding: 20px;
                    border-radius: 8px;
                    width: 90%;
                    max-height: 90vh;
                    overflow-y: auto;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }
                .modal-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 20px;
                    border-bottom: 1px solid #e2e8f0;
                    padding-bottom: 10px;
                }
                .close-btn {
                    background: none;
                    border: none;
                    font-size: 24px;
                    cursor: pointer;
                }
                .modal-footer {
                    margin-top: 20px;
                    text-align: right;
                    border-top: 1px solid #e2e8f0;
                    padding-top: 10px;
                }
            `}</style>
            {/* Incident Reporting Modal */}
            {showIncidentModal && (
                <div className="modal-overlay" onClick={() => setShowIncidentModal(false)}>
                    <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '500px' }}>
                        <div className="modal-header">
                            <h3>⚠️ Report Incident</h3>
                            <button className="close-btn" onClick={() => setShowIncidentModal(false)}>×</button>
                        </div>
                        <div className="modal-body">
                            <form onSubmit={async (e) => {
                                e.preventDefault();
                                try {
                                    await incidentsAPI.create(incidentForm);
                                    alert('Incident reported successfully! Admin notified.');
                                    setShowIncidentModal(false);
                                    setIncidentForm({ type: 'BIN_DAMAGED', description: '' });
                                } catch (err) {
                                    alert(err.message);
                                }
                            }}>
                                <div style={{ marginBottom: '15px' }}>
                                    <label style={{ display: 'block', marginBottom: '5px' }}>Issue Type</label>
                                    <select
                                        className="form-control"
                                        value={incidentForm.type}
                                        onChange={e => setIncidentForm({ ...incidentForm, type: e.target.value })}
                                        style={{ width: '100%', padding: '8px' }}
                                    >
                                        <option value="BIN_DAMAGED">Bin Damaged</option>
                                        <option value="ILLEGAL_DUMPING">Illegal Dumping</option>
                                        <option value="ACCESS_BLOCKED">Access Blocked</option>
                                        <option value="VEHICLE_ISSUE">Vehicle Issue</option>
                                        <option value="OTHER">Other</option>
                                    </select>
                                </div>
                                <div style={{ marginBottom: '15px' }}>
                                    <label style={{ display: 'block', marginBottom: '5px' }}>Description</label>
                                    <textarea
                                        className="form-control"
                                        rows="4"
                                        value={incidentForm.description}
                                        onChange={e => setIncidentForm({ ...incidentForm, description: e.target.value })}
                                        style={{ width: '100%', padding: '8px' }}
                                        required
                                        placeholder="Describe the issue clearly..."
                                    ></textarea>
                                </div>
                                <div style={{ textAlign: 'right' }}>
                                    <button type="button" className="btn btn-secondary" onClick={() => setShowIncidentModal(false)} style={{ marginRight: '10px' }}>Cancel</button>
                                    <button type="submit" className="btn btn-warning">Submit Report</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}

        </div>
    );
}

export default RoutesList;
