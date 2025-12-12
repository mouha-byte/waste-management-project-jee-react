import React, { useState, useEffect } from 'react';
import { collectionPointsAPI } from '../services/api';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix for default marker icon
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// Component to handle map clicks and update position
function LocationPicker({ position, onLocationSelect }) {
    const map = useMapEvents({
        click(e) {
            onLocationSelect(e.latlng);
            map.flyTo(e.latlng, map.getZoom());
        },
    });

    useEffect(() => {
        if (position) {
            map.flyTo(position, map.getZoom());
        }
    }, [position, map]);

    return position ? <Marker position={position} /> : null;
}

function PointForm({ point, onSave, onCancel }) {
    const [formData, setFormData] = useState({
        location: {
            latitude: '',
            longitude: '',
            address: ''
        },
        wasteType: 'PLASTIC',
        fillLevel: 0,
        status: 'ACTIVE',
        lastEmptied: new Date().toISOString().slice(0, 16)
    });
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);

    // Default center (Tunis)
    const defaultCenter = [36.8065, 10.1815];

    useEffect(() => {
        if (point) {
            setFormData({
                ...point,
                lastEmptied: point.lastEmptied ? new Date(point.lastEmptied).toISOString().slice(0, 16) : new Date().toISOString().slice(0, 16)
            });
        }
    }, [point]);

    const handleChange = (e) => {
        const { name, value } = e.target;

        if (name.startsWith('location.')) {
            const locationField = name.split('.')[1];
            setFormData({
                ...formData,
                location: {
                    ...formData.location,
                    [locationField]: locationField === 'address' ? value : parseFloat(value) || ''
                }
            });
        } else {
            setFormData({
                ...formData,
                [name]: name === 'fillLevel' ? parseInt(value) || 0 : value
            });
        }
    };

    const handleLocationSelect = (latlng) => {
        setFormData({
            ...formData,
            location: {
                ...formData.location,
                latitude: parseFloat(latlng.lat.toFixed(6)),
                longitude: parseFloat(latlng.lng.toFixed(6))
            }
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Validation
        if (!formData.location.address) {
            setError('Address is required');
            return;
        }

        if (!formData.location.latitude || !formData.location.longitude) {
            setError('Please select a location on the map');
            return;
        }

        if (formData.fillLevel < 0 || formData.fillLevel > 100) {
            setError('Fill level must be between 0 and 100');
            return;
        }

        try {
            setSaving(true);
            setError(null);

            if (point) {
                await collectionPointsAPI.update(point.id, formData);
            } else {
                await collectionPointsAPI.create(formData);
            }

            onSave();
        } catch (err) {
            setError('Failed to save collection point: ' + err.message);
        } finally {
            setSaving(false);
        }
    };

    const currentPosition = (formData.location.latitude && formData.location.longitude)
        ? [formData.location.latitude, formData.location.longitude]
        : null;

    return (
        <div className="card" style={{ maxWidth: '800px', margin: '0 auto' }}>
            <h2 style={{ borderBottom: '1px solid #e2e8f0', paddingBottom: '15px', marginBottom: '20px' }}>
                {point ? '✏️ Edit Collection Point' : '➕ Add New Collection Point'}
            </h2>

            {error && (
                <div className="alert-box error" style={{ marginBottom: '20px' }}>
                    {error}
                </div>
            )}

            <form onSubmit={handleSubmit} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>

                {/* Left Column: Form Fields */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
                    <div className="form-group">
                        <label>Address *</label>
                        <input
                            type="text"
                            name="location.address"
                            value={formData.location.address}
                            onChange={handleChange}
                            required
                            placeholder="e.g., 123 Rue de la Liberté"
                            className="form-control"
                        />
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                        <div className="form-group">
                            <label>Latitude</label>
                            <input
                                type="number"
                                step="0.000001"
                                name="location.latitude"
                                value={formData.location.latitude}
                                onChange={handleChange}
                                placeholder="Select on map"
                                readOnly
                                style={{ backgroundColor: '#f7fafc' }}
                            />
                        </div>
                        <div className="form-group">
                            <label>Longitude</label>
                            <input
                                type="number"
                                step="0.000001"
                                name="location.longitude"
                                value={formData.location.longitude}
                                onChange={handleChange}
                                placeholder="Select on map"
                                readOnly
                                style={{ backgroundColor: '#f7fafc' }}
                            />
                        </div>
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                        <div className="form-group">
                            <label>Waste Type *</label>
                            <select
                                name="wasteType"
                                value={formData.wasteType}
                                onChange={handleChange}
                                required
                            >
                                <option value="PLASTIC">Plastic</option>
                                <option value="GLASS">Glass</option>
                                <option value="ORGANIC">Organic</option>
                                <option value="GENERAL">General</option>
                            </select>
                        </div>

                        <div className="form-group">
                            <label>Status *</label>
                            <select
                                name="status"
                                value={formData.status}
                                onChange={handleChange}
                                required
                            >
                                <option value="ACTIVE">Active</option>
                                <option value="MAINTENANCE">Maintenance</option>
                                <option value="BROKEN">Broken</option>
                            </select>
                        </div>
                    </div>

                    <div className="form-group">
                        <label>Fill Level (%) *</label>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                            <input
                                type="range"
                                name="fillLevel"
                                min="0"
                                max="100"
                                value={formData.fillLevel}
                                onChange={handleChange}
                                style={{ flex: 1 }}
                            />
                            <span style={{ fontWeight: 'bold', width: '40px', textAlign: 'right' }}>{formData.fillLevel}%</span>
                        </div>
                        <div className="fill-level-bar" style={{ marginTop: '5px', height: '8px' }}>
                            <div
                                className={`fill-level-progress ${formData.fillLevel >= 90 ? 'high' : formData.fillLevel >= 70 ? 'medium' : 'low'}`}
                                style={{ width: `${formData.fillLevel}%` }}
                            ></div>
                        </div>
                    </div>

                    <div className="form-group">
                        <label>Last Emptied</label>
                        <input
                            type="datetime-local"
                            name="lastEmptied"
                            value={formData.lastEmptied}
                            onChange={handleChange}
                        />
                    </div>
                </div>

                {/* Right Column: Map */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                    <label style={{ fontWeight: '600', color: '#4a5568' }}>📍 Select Location on Map</label>
                    <div style={{ height: '400px', borderRadius: '8px', overflow: 'hidden', border: '2px solid #e2e8f0' }}>
                        <MapContainer
                            center={currentPosition || defaultCenter}
                            zoom={13}
                            style={{ height: '100%', width: '100%' }}
                        >
                            <TileLayer
                                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                            />
                            <LocationPicker
                                position={currentPosition}
                                onLocationSelect={handleLocationSelect}
                            />
                        </MapContainer>
                    </div>
                    <p style={{ fontSize: '0.85rem', color: '#718096', fontStyle: 'italic' }}>
                        Click anywhere on the map to set the collection point location.
                    </p>
                </div>

                {/* Full Width Actions */}
                <div className="form-actions" style={{ gridColumn: '1 / -1', marginTop: '20px', borderTop: '1px solid #e2e8f0', paddingTop: '20px' }}>
                    <button type="submit" className="btn btn-primary" disabled={saving}>
                        {saving ? 'Saving...' : (point ? 'Update Collection Point' : 'Create Collection Point')}
                    </button>
                    <button type="button" className="btn btn-secondary" onClick={onCancel} disabled={saving}>
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    );
}

export default PointForm;
