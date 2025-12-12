import React, { useState, useEffect } from 'react';
import { vehiclesAPI } from '../services/api';

function VehiclesList({ onEdit }) {
    const [vehicles, setVehicles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const [filterStatus, setFilterStatus] = useState('ALL');
    const [filterPlate, setFilterPlate] = useState('');

    useEffect(() => {
        loadVehicles();
    }, []);

    const loadVehicles = async () => {
        try {
            setLoading(true);
            const data = await vehiclesAPI.getAll();
            setVehicles(data);
            setError(null);
        } catch (err) {
            setError('Failed to load vehicles: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this vehicle?')) {
            return;
        }
        try {
            await vehiclesAPI.delete(id);
            loadVehicles();
        } catch (err) {
            setError('Failed to delete vehicle: ' + err.message);
        }
    };

    const getStatusBadgeClass = (status) => {
        switch (status) {
            case 'AVAILABLE': return 'active';
            case 'IN_USE': return 'maintenance';
            default: return 'broken';
        }
    };

    const filteredVehicles = vehicles.filter(vehicle => {
        const matchesStatus = filterStatus === 'ALL' || vehicle.status === filterStatus;
        const matchesPlate = vehicle.plateNumber.toLowerCase().includes(filterPlate.toLowerCase());
        return matchesStatus && matchesPlate;
    });

    if (loading) return <div className="loading"><div className="spinner"></div></div>;

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2>Vehicles</h2>
                <button className="btn btn-primary" onClick={() => onEdit(null)}>+ Add New Vehicle</button>
            </div>

            <div className="filters-section" style={{ display: 'flex', gap: '15px', marginBottom: '20px', padding: '15px', background: 'white', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '5px' }}>
                    <label style={{ fontSize: '12px', fontWeight: 'bold', color: '#4a5568' }}>Status</label>
                    <select
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value)}
                        style={{ padding: '8px', borderRadius: '4px', border: '1px solid #e2e8f0' }}
                    >
                        <option value="ALL">All Statuses</option>
                        <option value="AVAILABLE">Available</option>
                        <option value="IN_USE">In Use</option>
                        <option value="MAINTENANCE">Maintenance</option>
                    </select>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '5px' }}>
                    <label style={{ fontSize: '12px', fontWeight: 'bold', color: '#4a5568' }}>Plate Number</label>
                    <input
                        type="text"
                        placeholder="Search plate..."
                        value={filterPlate}
                        onChange={(e) => setFilterPlate(e.target.value)}
                        style={{ padding: '8px', borderRadius: '4px', border: '1px solid #e2e8f0' }}
                    />
                </div>
            </div>

            {error && <div className="alert-box error">{error}</div>}

            <table className="table">
                <thead>
                    <tr>
                        <th>Plate Number</th>
                        <th>Capacity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {filteredVehicles.map(vehicle => (
                        <tr key={vehicle.id}>
                            <td>{vehicle.plateNumber}</td>
                            <td>{vehicle.capacity} L</td>
                            <td>
                                <span className={`status-badge ${getStatusBadgeClass(vehicle.status)}`}>
                                    {vehicle.status}
                                </span>
                            </td>
                            <td>
                                <div className="table-actions">
                                    <button className="btn btn-secondary" onClick={() => onEdit(vehicle)} style={{ padding: '6px 12px', fontSize: '12px' }}>Edit</button>
                                    <button className="btn btn-danger" onClick={() => handleDelete(vehicle.id)} style={{ padding: '6px 12px', fontSize: '12px' }}>Delete</button>
                                </div>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default VehiclesList;
