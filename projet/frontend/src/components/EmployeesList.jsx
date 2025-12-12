import React, { useState, useEffect } from 'react';
import { employeesAPI } from '../services/api';

function EmployeesList({ onEdit }) {
    const [employees, setEmployees] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [filterRole, setFilterRole] = useState('ALL');
    const [filterAvailable, setFilterAvailable] = useState('ALL');

    useEffect(() => {
        loadEmployees();
    }, []);

    const loadEmployees = async () => {
        try {
            setLoading(true);
            const data = await employeesAPI.getAll();
            setEmployees(data);
            setError(null);
        } catch (err) {
            setError('Failed to load employees: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this employee?')) {
            return;
        }
        try {
            await employeesAPI.delete(id);
            loadEmployees();
        } catch (err) {
            setError('Failed to delete employee: ' + err.message);
        }
    };



    const filteredEmployees = employees.filter(emp => {
        const matchesRole = filterRole === 'ALL' || emp.role === filterRole;
        const matchesAvail = filterAvailable === 'ALL'
            ? true
            : filterAvailable === 'YES' ? emp.available
                : !emp.available;
        return matchesRole && matchesAvail;
    });

    if (loading) return <div className="loading"><div className="spinner"></div></div>;

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2>Employees</h2>
                <button className="btn btn-primary" onClick={() => onEdit(null)}>+ Add New Employee</button>
            </div>

            {/* Filters */}
            <div style={{ display: 'flex', gap: '15px', marginBottom: '20px', background: 'white', padding: '15px', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <label style={{ fontSize: '12px', marginBottom: '5px', color: '#718096' }}>Role</label>
                    <select
                        value={filterRole}
                        onChange={(e) => setFilterRole(e.target.value)}
                        style={{ padding: '8px', borderRadius: '4px', border: '1px solid #e2e8f0' }}
                    >
                        <option value="ALL">All Roles</option>
                        <option value="DRIVER">Driver</option>
                        <option value="COLLECTOR">Collector</option>
                    </select>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <label style={{ fontSize: '12px', marginBottom: '5px', color: '#718096' }}>Availability</label>
                    <select
                        value={filterAvailable}
                        onChange={(e) => setFilterAvailable(e.target.value)}
                        style={{ padding: '8px', borderRadius: '4px', border: '1px solid #e2e8f0' }}
                    >
                        <option value="ALL">All Statuses</option>
                        <option value="YES">Available</option>
                        <option value="NO">Unavailable</option>
                    </select>
                </div>
            </div>

            {error && <div className="alert-box error">{error}</div>}

            <table className="table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Role</th>

                        <th>Status</th>
                        <th>Competencies</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {filteredEmployees.map(emp => (
                        <tr key={emp.id}>
                            <td>{emp.name}</td>
                            <td>{emp.role}</td>

                            <td>
                                <span className={`status-badge ${emp.available ? 'active' : 'broken'}`}>
                                    {emp.available ? 'Available' : 'Unavailable'}
                                </span>
                            </td>
                            <td>
                                <div style={{ display: 'flex', gap: '5px', flexWrap: 'wrap' }}>
                                    {emp.competencies?.map(c => (
                                        <span key={c} style={{ fontSize: '10px', background: '#e2e8f0', padding: '2px 6px', borderRadius: '4px' }}>{c}</span>
                                    ))}
                                </div>
                            </td>
                            <td>
                                <div className="table-actions">
                                    <button className="btn btn-secondary" onClick={() => onEdit(emp)} style={{ padding: '6px 12px', fontSize: '12px' }}>Edit</button>

                                    <button className="btn btn-danger" onClick={() => handleDelete(emp.id)} style={{ padding: '6px 12px', fontSize: '12px' }}>Delete</button>
                                </div>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default EmployeesList;
