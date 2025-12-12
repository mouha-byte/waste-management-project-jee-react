import React, { useState, useEffect } from 'react';
import { employeesAPI } from '../services/api';

function EmployeeForm({ employee, onSave, onCancel }) {
    const [formData, setFormData] = useState({
        name: '',
        role: 'COLLECTOR',

        available: true,
        competencies: []
    });
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (employee) {
            setFormData(employee);
        }
    }, [employee]);

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData({
            ...formData,
            [name]: type === 'checkbox' ? checked : value
        });
    };

    const handleCompetencyChange = (e) => {
        const { value, checked } = e.target;
        let newCompetencies = [...formData.competencies];

        if (checked) {
            newCompetencies.push(value);
        } else {
            newCompetencies = newCompetencies.filter(c => c !== value);
        }

        setFormData({
            ...formData,
            competencies: newCompetencies
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!formData.name) {
            setError('Name is required');
            return;
        }

        try {
            setSaving(true);
            setError(null);

            // Note: The API service currently only has create, we might need to add update if not present
            // But assuming we'll add it or it exists. Let's check api.js content later.
            // For now, I'll assume create works for both or I'll fix api.js

            // Actually, looking at api.js provided earlier, it only had create. 
            // I should update api.js to include update and delete for employees/vehicles/routes too.
            // But for now let's write this component assuming the API exists, and I will update api.js next.

            if (employee && employee.id) {
                // await employeesAPI.update(employee.id, formData); // To be implemented
                // For now, let's just use create as placeholder or handle it after updating api.js
                // I will update api.js in the next step to support full CRUD.
                await employeesAPI.update(employee.id, formData);
            } else {
                await employeesAPI.create(formData);
            }

            onSave();
        } catch (err) {
            setError('Failed to save employee: ' + err.message);
        } finally {
            setSaving(false);
        }
    };

    return (
        <div>
            <h2>{employee ? 'Edit Employee' : 'Add New Employee'}</h2>

            {error && (
                <div className="alert-box error">
                    {error}
                </div>
            )}

            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label>Name *</label>
                    <input
                        type="text"
                        name="name"
                        value={formData.name}
                        onChange={handleChange}
                        required
                        placeholder="Jean Dupont"
                    />
                </div>

                <div className="form-group">
                    <label>Role *</label>
                    <select name="role" value={formData.role} onChange={handleChange}>
                        <option value="COLLECTOR">Collector</option>
                        <option value="DRIVER">Driver</option>
                    </select>
                </div>



                <div className="form-group">
                    <label>
                        <input
                            type="checkbox"
                            name="available"
                            checked={formData.available}
                            onChange={handleChange}
                            style={{ width: 'auto', marginRight: '10px' }}
                        />
                        Available
                    </label>
                </div>

                <div className="form-group">
                    <label>Competencies</label>
                    <div style={{ display: 'flex', gap: '15px', flexWrap: 'wrap' }}>
                        {['PLASTIC', 'GLASS', 'ORGANIC', 'GENERAL'].map(type => (
                            <label key={type} style={{ fontWeight: 'normal', display: 'flex', alignItems: 'center', gap: '5px' }}>
                                <input
                                    type="checkbox"
                                    value={type}
                                    checked={formData.competencies.includes(type)}
                                    onChange={handleCompetencyChange}
                                    style={{ width: 'auto' }}
                                />
                                {type}
                            </label>
                        ))}
                    </div>
                </div>

                <div className="form-actions">
                    <button type="submit" className="btn btn-primary" disabled={saving}>
                        {saving ? 'Saving...' : (employee ? 'Update' : 'Create')}
                    </button>
                    <button type="button" className="btn btn-secondary" onClick={onCancel} disabled={saving}>
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    );
}

export default EmployeeForm;
