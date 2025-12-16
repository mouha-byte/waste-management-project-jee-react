import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { API_BASE_URL } from '../services/api';

const ServerMonitor = () => {
    const { token } = useAuth();
    const [health, setHealth] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [lastUpdated, setLastUpdated] = useState(new Date());

    const fetchHealth = async () => {
        try {
            const response = await fetch(`${API_BASE_URL}/monitoring/health`);
            if (!response.ok) throw new Error('Failed to fetch metrics');
            const data = await response.json();
            setHealth(data);
            setLastUpdated(new Date());
            setError(null);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchHealth();
        const interval = setInterval(fetchHealth, 5000); // Poll every 5 seconds
        return () => clearInterval(interval);
    }, []);

    const formatBytes = (bytes) => {
        if (!bytes) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    const formatUptime = (ms) => {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);
        return `${days}d ${hours % 24}h ${minutes % 60}m ${seconds % 60}s`;
    };

    if (loading && !health) return <div className="loading"><div className="spinner"></div></div>;

    return (
        <div className="server-monitor">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2>🖥️ Server Supervision</h2>
                <span style={{ fontSize: '0.9rem', color: '#666' }}>Last updated: {lastUpdated.toLocaleTimeString()}</span>
            </div>

            {error && <div className="alert-box error">{error}</div>}

            {health && (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>

                    {/* Memory Card */}
                    <div className="card" style={{ padding: '20px', background: 'white', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                        <h3>💾 Memory Usage (JVM)</h3>
                        <div style={{ margin: '20px 0' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '5px' }}>
                                <span>Used</span>
                                <span>{Math.round((health.usedMemory / health.maxMemory) * 100)}%</span>
                            </div>
                            <div style={{ width: '100%', height: '20px', background: '#e0e0e0', borderRadius: '10px', overflow: 'hidden' }}>
                                <div style={{
                                    width: `${(health.usedMemory / health.maxMemory) * 100}%`,
                                    height: '100%',
                                    background: 'linear-gradient(90deg, #4CAF50, #8BC34A)',
                                    transition: 'width 0.5s ease-in-out'
                                }}></div>
                            </div>
                        </div>
                        <div style={{ fontSize: '0.9rem', color: '#555', lineHeight: '1.6' }}>
                            <div>Total Used: <strong>{formatBytes(health.usedMemory)}</strong></div>
                            <div>Free: {formatBytes(health.freeMemory)}</div>
                            <div>Max Allocatable: {formatBytes(health.maxMemory)}</div>
                        </div>
                    </div>

                    {/* CPU & Threads Card */}
                    <div className="card" style={{ padding: '20px', background: 'white', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                        <h3>⚡ CPU & Threads</h3>
                        <div style={{ fontSize: '1.1rem', marginBottom: '15px' }}>
                            Loader Average: <strong>{health.systemLoad < 0 ? 'N/A (Windows)' : health.systemLoad.toFixed(2)}</strong>
                        </div>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                            <div style={{ background: '#f8f9fa', padding: '10px', borderRadius: '6px', textAlign: 'center' }}>
                                <div style={{ fontSize: '2rem', color: '#2196F3' }}>{health.availableProcessors}</div>
                                <div style={{ fontSize: '0.8rem', color: '#666' }}>Cores</div>
                            </div>
                            <div style={{ background: '#f8f9fa', padding: '10px', borderRadius: '6px', textAlign: 'center' }}>
                                <div style={{ fontSize: '2rem', color: '#9C27B0' }}>{health.activeThreads}</div>
                                <div style={{ fontSize: '0.8rem', color: '#666' }}>Threads</div>
                            </div>
                        </div>
                    </div>

                    {/* Uptime Card */}
                    <div className="card" style={{ padding: '20px', background: 'white', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                        <h3>⏱️ Uptime</h3>
                        <div style={{
                            fontSize: '2rem',
                            fontWeight: 'bold',
                            color: '#FF9800',
                            textAlign: 'center',
                            padding: '20px 0'
                        }}>
                            {formatUptime(health.uptime)}
                        </div>
                        <div style={{ textAlign: 'center', color: '#666' }}>Since Server Start</div>
                    </div>

                </div>
            )}
        </div>
    );
};

export default ServerMonitor;
