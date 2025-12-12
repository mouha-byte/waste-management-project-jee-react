import React from 'react';
import { useAuth } from '../context/AuthContext';
import Login from './Login';

const PrivateRoute = ({ children, roles }) => {
    const { user } = useAuth();

    if (!user) {
        return <Login />;
    }

    if (roles && !roles.includes(user.role)) {
        return (
            <div style={{ padding: '50px', textAlign: 'center' }}>
                <h2>⛔ Access Denied</h2>
                <p>You do not have permission to view this page.</p>
                <p>Required roles: {roles.join(', ')}</p>
                <p>Your role: {user.role}</p>
            </div>
        );
    }

    return children;
};

export default PrivateRoute;
