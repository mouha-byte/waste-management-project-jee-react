import React, { useState, useEffect } from 'react';
import { collectionPointsAPI } from '../services/api';

function PointsList({ onEdit }) {
    const [points, setPoints] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [filterType, setFilterType] = useState('ALL');
    const [filterStatus, setFilterStatus] = useState('ALL');

    useEffect(() => {
        loadPoints();
    }, []);

    const loadPoints = async () => {
        try {
            setLoading(true);
            const data = await collectionPointsAPI.getAll();
            setPoints(data);
            setError(null);
        } catch (err) {
            setError('Failed to load collection points: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this collection point?')) {
            return;
        }

        try {
            await collectionPointsAPI.delete(id);
            loadPoints(); // Reload the list
        } catch (err) {
            setError('Failed to delete collection point: ' + err.message);
        }
    };

    const getFillLevelClass = (level) => {
        if (level >= 90) return 'high';
        if (level >= 70) return 'medium';
        return 'low';
    };

    const getStatusBadgeClass = (status) => {
        return status.toLowerCase();
    };

    const filteredPoints = points.filter(point => {
        const matchesType = filterType === 'ALL' || point.wasteType === filterType;
        const matchesStatus = filterStatus === 'ALL' || point.status === filterStatus;
        return matchesType && matchesStatus;
    });

    if (loading) {
        return (
            <div className="loading">
                <div className="spinner"></div>
            </div>
        );
    }

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2>Collection Points</h2>
                <button className="btn btn-primary" onClick={() => onEdit(null)}>
                    + Add New Point
                </button>
            </div>

            {/* Filters */}
            <div style={{ display: 'flex', gap: '15px', marginBottom: '20px', background: 'white', padding: '15px', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <label style={{ fontSize: '12px', marginBottom: '5px', color: '#718096' }}>Waste Type</label>
                    <select
                        value={filterType}
                        onChange={(e) => setFilterType(e.target.value)}
                        style={{ padding: '8px', borderRadius: '4px', border: '1px solid #e2e8f0' }}
                    >
                        <option value="ALL">All Types</option>
                        <option value="PLASTIC">Plastic</option>
                        <option value="GLASS">Glass</option>
                        <option value="ORGANIC">Organic</option>
                        <option value="GENERAL">General</option>
                    </select>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <label style={{ fontSize: '12px', marginBottom: '5px', color: '#718096' }}>Status</label>
                    <select
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value)}
                        style={{ padding: '8px', borderRadius: '4px', border: '1px solid #e2e8f0' }}
                    >
                        <option value="ALL">All Statuses</option>
                        <option value="ACTIVE">Active</option>
                        <option value="MAINTENANCE">Maintenance</option>
                        <option value="BROKEN">Broken</option>
                    </select>
                </div>
            </div>

            {error && (
                <div className="alert-box error">
                    {error}
                </div>
            )}

            {filteredPoints.length === 0 ? (
                <div className="alert-box info">
                    No collection points found matching your filters.
                </div>
            ) : (
                <table className="table">
                    <thead>
                        <tr>
                            <th>Address</th>
                            <th>Waste Type</th>
                            <th>Fill Level</th>
                            <th>Status</th>
                            <th>Alert</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filteredPoints.map((point) => (
                            <tr key={point.id}>
                                <td>{point.location?.address || 'N/A'}</td>
                                <td>{point.wasteType}</td>
                                <td>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                        <div className="fill-level-bar">
                                            <div
                                                className={`fill-level-progress ${getFillLevelClass(point.fillLevel)}`}
                                                style={{ width: `${point.fillLevel}%` }}
                                            ></div>
                                        </div>
                                        <span>{point.fillLevel}%</span>
                                    </div>
                                </td>
                                <td>
                                    <span className={`status-badge ${getStatusBadgeClass(point.status)}`}>
                                        {point.status}
                                    </span>
                                </td>
                                <td>
                                    {point.fillLevel >= 90 && (
                                        <span className="alert-badge high">⚠️ URGENT</span>
                                    )}
                                    {point.fillLevel >= 80 && point.fillLevel < 90 && (
                                        <span className="alert-badge medium">⚡ Soon</span>
                                    )}
                                </td>
                                <td>
                                    <div className="table-actions">
                                        <button
                                            className="btn btn-secondary"
                                            onClick={() => onEdit(point)}
                                            style={{ padding: '6px 12px', fontSize: '12px' }}
                                        >
                                            Edit
                                        </button>
                                        <button
                                            className="btn btn-danger"
                                            onClick={() => handleDelete(point.id)}
                                            style={{ padding: '6px 12px', fontSize: '12px' }}
                                        >
                                            Delete
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}

export default PointsList;
