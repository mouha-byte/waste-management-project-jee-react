import React, { useState, useEffect } from 'react';
import { collectionPointsAPI, employeesAPI, vehiclesAPI, routesAPI } from '../services/api';
import { useTranslation } from 'react-i18next';

function Statistics() {
    const { t } = useTranslation();
    const [stats, setStats] = useState({
        points: [],
        employees: [],
        vehicles: [],
        routes: []
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchAllData();
    }, []);

    const fetchAllData = async () => {
        try {
            const [pointsData, employeesData, vehiclesData, routesData] = await Promise.all([
                collectionPointsAPI.getAll(),
                employeesAPI.getAll(),
                vehiclesAPI.getAll(),
                routesAPI.getAll()
            ]);
            setStats({
                points: pointsData,
                employees: employeesData,
                vehicles: vehiclesData,
                routes: routesData
            });
        } catch (error) {
            console.error("Error fetching statistics:", error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="loading"><div className="spinner"></div></div>;

    // Helper to calculate percentages
    const calcPct = (count, total) => total > 0 ? ((count / total) * 100).toFixed(1) : 0;

    // derived stats
    const totalPoints = stats.points.length;
    const highFillPoints = stats.points.filter(p => p.fillLevel >= 90).length;
    const medFillPoints = stats.points.filter(p => p.fillLevel >= 50 && p.fillLevel < 90).length;
    const lowFillPoints = stats.points.filter(p => p.fillLevel < 50).length;

    const activeVehicles = stats.vehicles.filter(v => v.status === 'IN_USE').length;
    const totalVehicles = stats.vehicles.length;

    const completedRoutes = stats.routes.filter(r => r.status === 'COMPLETED').length;
    const activeRoutes = stats.routes.filter(r => r.status === 'IN_PROGRESS').length;
    const totalRoutes = stats.routes.length;

    return (
        <div>
            <h2 style={{ marginBottom: '20px', color: 'var(--text-primary)' }}>📈 {t('stats.title') || 'Detailed Statistics'}</h2>

            <div className="dashboard-grid">
                {/* Points Card */}
                <div className="dashboard-card">
                    <h3>🗑️ Waste Analysis</h3>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
                        <div>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '5px', fontSize: '14px', color: 'var(--text-secondary)' }}>
                                <span>Critical (&gt;90%)</span>
                                <span>{highFillPoints} ({calcPct(highFillPoints, totalPoints)}%)</span>
                            </div>
                            <div className="fill-level-bar" style={{ width: '100%' }}>
                                <div className="fill-level-progress high" style={{ width: `${calcPct(highFillPoints, totalPoints)}%` }}></div>
                            </div>
                        </div>
                        <div>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '5px', fontSize: '14px', color: 'var(--text-secondary)' }}>
                                <span>Warning (50-89%)</span>
                                <span>{medFillPoints} ({calcPct(medFillPoints, totalPoints)}%)</span>
                            </div>
                            <div className="fill-level-bar" style={{ width: '100%' }}>
                                <div className="fill-level-progress medium" style={{ width: `${calcPct(medFillPoints, totalPoints)}%` }}></div>
                            </div>
                        </div>
                        <div>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '5px', fontSize: '14px', color: 'var(--text-secondary)' }}>
                                <span>Normal (&lt;50%)</span>
                                <span>{lowFillPoints} ({calcPct(lowFillPoints, totalPoints)}%)</span>
                            </div>
                            <div className="fill-level-bar" style={{ width: '100%' }}>
                                <div className="fill-level-progress low" style={{ width: `${calcPct(lowFillPoints, totalPoints)}%` }}></div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Fleet Card */}
                <div className="dashboard-card">
                    <h3>🚛 Fleet Utilization</h3>
                    <div style={{ textAlign: 'center', margin: '20px 0' }}>
                        <div style={{ fontSize: '48px', fontWeight: 'bold', color: 'var(--accent-color)' }}>
                            {calcPct(activeVehicles, totalVehicles)}%
                        </div>
                        <div style={{ color: 'var(--text-secondary)' }}>Active Fleet Usage</div>
                    </div>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', textAlign: 'center' }}>
                        <div style={{ background: 'var(--bg-primary)', padding: '10px', borderRadius: '8px' }}>
                            <div style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>{activeVehicles}</div>
                            <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>On Road</div>
                        </div>
                        <div style={{ background: 'var(--bg-primary)', padding: '10px', borderRadius: '8px' }}>
                            <div style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>{totalVehicles - activeVehicles}</div>
                            <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Parked</div>
                        </div>
                    </div>
                </div>

                {/* Routes Card */}
                <div className="dashboard-card">
                    <h3>🗺️ Route Performance</h3>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '15px' }}>
                        <span>Completion Rate</span>
                        <span style={{ fontWeight: 'bold', color: 'var(--success-color)' }}>{calcPct(completedRoutes, totalRoutes)}%</span>
                    </div>
                    <div style={{ height: '10px', background: 'var(--bg-primary)', borderRadius: '5px', overflow: 'hidden', marginBottom: '20px' }}>
                        <div style={{ width: `${calcPct(completedRoutes, totalRoutes)}%`, background: 'var(--success-color)', height: '100%' }}></div>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
                            <span style={{ color: 'var(--text-secondary)' }}>Active Now</span>
                            <span style={{ fontWeight: 'bold', color: 'var(--accent-color)' }}>{activeRoutes}</span>
                        </div>
                        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
                            <span style={{ color: 'var(--text-secondary)' }}>Total Planned</span>
                            <span style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>{totalRoutes}</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* Detailed Data Tables - Collapsible or Tabled */}
            <h3 style={{ marginTop: '30px', color: 'var(--text-primary)' }}>📋 All System Data</h3>

            <div style={{ background: 'var(--bg-card)', padding: '20px', borderRadius: '12px', marginTop: '15px', border: '1px solid var(--border-color)' }}>
                <h4 style={{ marginBottom: '15px', color: 'var(--text-primary)' }}>Breakdown by Type</h4>
                <div style={{ overflowX: 'auto' }}>
                    <table className="table">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Metric</th>
                                <th>Value</th>
                                <th>Target</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Collection</td>
                                <td>Average Fill Level</td>
                                <td>
                                    {stats.points.length > 0
                                        ? Math.round(stats.points.reduce((acc, p) => acc + p.fillLevel, 0) / stats.points.length)
                                        : 0}%
                                </td>
                                <td>&lt; 70%</td>
                            </tr>
                            <tr>
                                <td>Collection</td>
                                <td>Critical Points</td>
                                <td style={{ color: 'var(--danger-color)', fontWeight: 'bold' }}>{highFillPoints}</td>
                                <td>0</td>
                            </tr>
                            <tr>
                                <td>Workforce</td>
                                <td>Total Employees</td>
                                <td>{stats.employees.length}</td>
                                <td>-</td>
                            </tr>
                            <tr>
                                <td>Workforce</td>
                                <td>Active Drivers</td>
                                <td>{stats.employees.filter(e => !e.available).length}</td>
                                <td>-</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}

export default Statistics;
