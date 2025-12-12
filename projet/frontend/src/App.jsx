import React, { useState } from 'react';
import './index.css';
import Dashboard from './components/Dashboard';
import PointsList from './components/PointsList';
import PointForm from './components/PointForm';
import EmployeesList from './components/EmployeesList';
import EmployeeForm from './components/EmployeeForm';
import VehiclesList from './components/VehiclesList';
import VehicleForm from './components/VehicleForm';
import RoutesList from './components/RoutesList';
import MapComponent from './components/MapComponent';
import Statistics from './components/Statistics'; // Import Statistics
import { AuthProvider, useAuth } from './context/AuthContext';
import PrivateRoute from './components/PrivateRoute';

import { useTheme } from './context/ThemeContext';
import { useTranslation } from 'react-i18next';

function AppContent() {
    const [currentView, setCurrentView] = useState('dashboard');
    const [editingItem, setEditingItem] = useState(null);
    const [showHelp, setShowHelp] = useState(false);
    const { user, logout } = useAuth();
    const { theme, toggleTheme } = useTheme();
    const { t, i18n } = useTranslation();

    // Generic handler for editing items
    const handleEdit = (item, viewName) => {
        setEditingItem(item);
        setCurrentView(viewName);
    };

    const handleSave = () => {
        setEditingItem(null);
        if (currentView === 'pointForm') setCurrentView('points');
        if (currentView === 'employeeForm') setCurrentView('employees');
        if (currentView === 'vehicleForm') setCurrentView('vehicles');
    };

    const handleCancel = () => {
        setEditingItem(null);
        if (currentView === 'pointForm') setCurrentView('points');
        if (currentView === 'employeeForm') setCurrentView('employees');
        if (currentView === 'vehicleForm') setCurrentView('vehicles');
    };

    const changeLanguage = (lng) => {
        i18n.changeLanguage(lng);
    };

    const SidebarItem = ({ id, icon, label, restrictedTo }) => {
        if (restrictedTo && !restrictedTo.includes(user?.role)) return null;
        return (
            <button
                className={`sidebar-link ${currentView === id || currentView.startsWith(id.slice(0, -1)) ? 'active' : ''}`}
                onClick={() => setCurrentView(id)}
                style={{
                    display: 'flex',
                    alignItems: 'center',
                    width: '100%',
                    padding: '12px 15px',
                    background: (currentView === id || (id !== 'dashboard' && currentView.startsWith(id.slice(0, -1)))) ? 'var(--accent-color)' : 'transparent',
                    color: (currentView === id || (id !== 'dashboard' && currentView.startsWith(id.slice(0, -1)))) ? '#ffffff' : 'var(--text-secondary)',
                    border: 'none',
                    borderRadius: '8px',
                    marginBottom: '5px',
                    cursor: 'pointer',
                    textAlign: 'left',
                    fontSize: '1rem',
                    transition: 'all 0.2s'
                }}
            >
                <span style={{ marginRight: '10px', fontSize: '1.2rem' }}>{icon}</span>
                {label}
            </button>
        );
    };

    return (
        <PrivateRoute roles={['ADMIN', 'MANAGER', 'DRIVER']}>
            <div className="app-container" style={{ display: 'flex', height: '100vh', overflow: 'hidden', background: 'var(--bg-primary)' }}>
                {/* Sidebar */}
                <div className="sidebar" style={{
                    width: '260px',
                    background: 'var(--sidebar-bg)',
                    color: 'var(--text-primary)',
                    display: 'flex',
                    flexDirection: 'column',
                    padding: '20px',
                    boxShadow: '2px 0 5px rgba(0,0,0,0.05)',
                    borderRight: '1px solid var(--border-color)',
                    transition: 'background 0.3s'
                }}>
                    <div style={{ marginBottom: '30px', textAlign: 'center' }}>
                        <h1 style={{ fontSize: '1.5rem', margin: '0 0 5px 0', color: 'var(--accent-color)' }}>♻️ EcoWaste</h1>
                        <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Smart Management System</p>
                    </div>

                    <nav style={{ flex: 1 }}>
                        <SidebarItem id="dashboard" icon="📊" label={t('dashboard')} />
                        <SidebarItem id="stats" icon="📈" label={t('stats.title') || 'Statistics'} />
                        <SidebarItem id="map" icon="🌍" label={t('map.title')} />
                        <SidebarItem id="routes" icon="🗺️" label={t('routes')} />
                        <SidebarItem id="points" icon="📍" label={t('points')} />
                        <SidebarItem id="employees" icon="👷" label={t('employees')} restrictedTo={['ADMIN', 'MANAGER']} />
                        <SidebarItem id="vehicles" icon="🚛" label={t('vehicles')} restrictedTo={['ADMIN', 'MANAGER']} />
                    </nav>

                    {/* Settings / Toggles */}
                    <div style={{ marginBottom: '20px', padding: '10px', background: 'rgba(0,0,0,0.03)', borderRadius: '8px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                            <button onClick={toggleTheme} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1.2rem' }} title={theme === 'light' ? t('darkMode') : t('lightMode')}>
                                {theme === 'light' ? '🌙' : '☀️'}
                            </button>
                            <div style={{ display: 'flex', gap: '5px' }}>
                                <button onClick={() => changeLanguage('en')} style={{ cursor: 'pointer', border: 'none', background: i18n.language === 'en' ? 'var(--accent-color)' : 'transparent', color: i18n.language === 'en' ? 'white' : 'var(--text-primary)', borderRadius: '4px', padding: '2px 5px' }}>EN</button>
                                <button onClick={() => changeLanguage('fr')} style={{ cursor: 'pointer', border: 'none', background: i18n.language === 'fr' ? 'var(--accent-color)' : 'transparent', color: i18n.language === 'fr' ? 'white' : 'var(--text-primary)', borderRadius: '4px', padding: '2px 5px' }}>FR</button>
                                <button onClick={() => changeLanguage('ar')} style={{ cursor: 'pointer', border: 'none', background: i18n.language === 'ar' ? 'var(--accent-color)' : 'transparent', color: i18n.language === 'ar' ? 'white' : 'var(--text-primary)', borderRadius: '4px', padding: '2px 5px' }}>AR</button>
                            </div>
                        </div>
                    </div>

                    <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '20px' }}>
                        <button
                            onClick={() => setShowHelp(true)}
                            style={{ width: '100%', padding: '10px', background: 'var(--bg-primary)', color: 'var(--text-primary)', border: '1px solid var(--border-color)', borderRadius: '6px', marginBottom: '10px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                        >
                            ❓ Help & Support
                        </button>
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                            <div>
                                <div style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>{user?.username}</div>
                                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{user?.role}</div>
                            </div>
                            <button onClick={logout} style={{ background: 'none', border: 'none', color: 'var(--danger-color)', cursor: 'pointer', fontSize: '0.9rem' }}>
                                ↪️ {t('logout')}
                            </button>
                        </div>
                    </div>
                </div>

                {/* Main Content */}
                <div className="main-content" style={{ flex: 1, background: 'var(--bg-primary)', color: 'var(--text-primary)', overflowY: 'auto', padding: '30px', transition: 'background 0.3s' }}>
                    {currentView === 'dashboard' && <Dashboard />}
                    {currentView === 'map' && <MapComponent height="85vh" />}

                    {currentView === 'points' && <PointsList onEdit={(item) => handleEdit(item, 'pointForm')} />}
                    {currentView === 'pointForm' && <PointForm point={editingItem} onSave={handleSave} onCancel={handleCancel} />}

                    {currentView === 'employees' && (
                        <PrivateRoute roles={['ADMIN', 'MANAGER']}>
                            <EmployeesList onEdit={(item) => handleEdit(item, 'employeeForm')} />
                        </PrivateRoute>
                    )}
                    {currentView === 'employeeForm' && (
                        <PrivateRoute roles={['ADMIN', 'MANAGER']}>
                            <EmployeeForm employee={editingItem} onSave={handleSave} onCancel={handleCancel} />
                        </PrivateRoute>
                    )}

                    {currentView === 'vehicles' && (
                        <PrivateRoute roles={['ADMIN', 'MANAGER']}>
                            <VehiclesList onEdit={(item) => handleEdit(item, 'vehicleForm')} />
                        </PrivateRoute>
                    )}
                    {currentView === 'vehicleForm' && (
                        <PrivateRoute roles={['ADMIN', 'MANAGER']}>
                            <VehicleForm vehicle={editingItem} onSave={handleSave} onCancel={handleCancel} />
                        </PrivateRoute>
                    )}

                    {currentView === 'routes' && <RoutesList />}
                    {currentView === 'stats' && <Statistics />}
                </div>

                {/* Help Modal */}
                {showHelp && (
                    <div className="modal-overlay" onClick={() => setShowHelp(false)} style={{
                        position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 2000
                    }}>
                        <div className="modal-content" onClick={e => e.stopPropagation()} style={{ background: 'var(--bg-card)', padding: '30px', borderRadius: '12px', maxWidth: '500px', width: '90%', border: '1px solid var(--border-color)' }}>
                            <h2 style={{ marginTop: 0, color: 'var(--text-primary)' }}>❓ Help & Documentation</h2>
                            <div style={{ margin: '20px 0', lineHeight: '1.6', color: 'var(--text-secondary)' }}>
                                <p><strong>{t('dashboard')}:</strong> View live stats, active alerts, and generate reports.</p>
                                <p><strong>{t('map.title')}:</strong> Real-time view of all collection points and their status.</p>
                                <p><strong>{t('routes')}:</strong> Generate optimized routes based on fill levels.</p>
                                <div style={{ background: 'var(--bg-primary)', padding: '10px', borderRadius: '6px', marginTop: '15px', color: 'var(--text-primary)' }}>
                                    <strong>💡 Tip:</strong> Use the "Generate Route" button to automatically create the most efficient path.
                                </div>
                            </div>
                            <button className="btn btn-primary" onClick={() => setShowHelp(false)} style={{ width: '100%' }}>Close</button>
                        </div>
                    </div>
                )}
            </div>
        </PrivateRoute>
    );
}

function App() {
    return (
        <AuthProvider>
            <AppContent />
        </AuthProvider>
    );
}

export default App;
