import React, { useState, useEffect } from 'react';
import { vehiclesAPI } from '../services/api';

function VehicleForm({ vehicle, onSave, onCancel }) {
    const [formData, setFormData] = useState({
        plateNumber: '',
        capacity: 1000,
        status: 'AVAILABLE',
        currentLocation: {
            latitude: 0,
            longitude: 0
        }
    });
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (vehicle) {
            setFormData(vehicle);
        }
    }, [vehicle]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({
            ...formData,
            [name]: name === 'capacity' ? parseInt(value) : value
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!formData.plateNumber) {
            setError('Plate number is required');
            return;
        }

        try {
            setSaving(true);
            setError(null);

            if (vehicle && vehicle.id) {
                await vehiclesAPI.update(vehicle.id, formData);
            } else {
                await vehiclesAPI.create(formData);
            }

            onSave();
        } catch (err) {
            setError('Failed to save vehicle: ' + err.message);
        } finally {
            setSaving(false);
        }
    };

    return (
        <div>
            <h2>{vehicle ? 'Edit Vehicle' : 'Add New Vehicle'}</h2>

            {error && <div className="alert-box error">{error}</div>}

            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label>Plate Number *</label>
                    <input
                        type="text"
                        name="plateNumber"
                        value={formData.plateNumber}
                        onChange={handleChange}
                        required
                        placeholder="AB-123-CD"
                    />
                </div>

                <div className="form-group">
                    <label>Capacity (Liters) *</label>
                    <input
                        type="number"
                        name="capacity"
                        value={formData.capacity}
                        onChange={handleChange}
                        required
                        min="100"
                    />
                </div>

                <div className="form-group">
                    <label>Status *</label>
                    <select name="status" value={formData.status} onChange={handleChange}>
                        <option value="AVAILABLE">Available</option>
                        <option value="IN_USE">In Use</option>
                        <option value="MAINTENANCE">Maintenance</option>
                    </select>
                </div>

                <div className="form-actions">
                    <button type="submit" className="btn btn-primary" disabled={saving}>
                        {saving ? 'Saving...' : (vehicle ? 'Update' : 'Create')}
                    </button>
                    <button type="button" className="btn btn-secondary" onClick={onCancel} disabled={saving}>
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    );
}

export default VehicleForm;
