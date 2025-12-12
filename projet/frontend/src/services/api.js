const API_BASE_URL = 'http://localhost:8086/api';

const getHeaders = () => {
    const token = localStorage.getItem('token');
    return {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {})
    };
};

// Collection Points API
export const collectionPointsAPI = {
    getAll: async () => {
        const response = await fetch(`${API_BASE_URL}/points`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch collection points');
        return response.json();
    },

    getById: async (id) => {
        const response = await fetch(`${API_BASE_URL}/points/${id}`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch collection point');
        return response.json();
    },

    create: async (point) => {
        const response = await fetch(`${API_BASE_URL}/points`, {
            method: 'POST',
            headers: getHeaders(),
            body: JSON.stringify(point)
        });
        if (!response.ok) throw new Error('Failed to create collection point');
        return response.json();
    },

    update: async (id, point) => {
        const response = await fetch(`${API_BASE_URL}/points/${id}`, {
            method: 'PUT',
            headers: getHeaders(),
            body: JSON.stringify(point)
        });
        if (!response.ok) throw new Error('Failed to update collection point');
        return response.json();
    },

    delete: async (id) => {
        const response = await fetch(`${API_BASE_URL}/points/${id}`, {
            method: 'DELETE',
            headers: getHeaders()
        });
        if (!response.ok) throw new Error('Failed to delete collection point');
    },

    getAlerts: async () => {
        const response = await fetch(`${API_BASE_URL}/points/alerts`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch alerts');
        return response.json();
    },

    getNeedingCollection: async () => {
        const response = await fetch(`${API_BASE_URL}/points/needing-collection`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch points needing collection');
        return response.json();
    }
};

// Routes API
export const routesAPI = {
    getAll: async () => {
        const response = await fetch(`${API_BASE_URL}/routes`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch routes');
        return response.json();
    },

    generateOptimized: async () => {
        const response = await fetch(`${API_BASE_URL}/routes/generate`, {
            method: 'POST',
            headers: getHeaders()
        });
        if (!response.ok) throw new Error('Failed to generate route');
        return response.json();
    },

    updateStatus: async (id, status) => {
        const response = await fetch(`${API_BASE_URL}/routes/${id}/status?status=${status}`, {
            method: 'PATCH',
            headers: getHeaders()
        });
        if (!response.ok) throw new Error('Failed to update route status');
        return response.json();
    },

    delete: async (id) => {
        const response = await fetch(`${API_BASE_URL}/routes/${id}`, {
            method: 'DELETE',
            headers: getHeaders()
        });
        if (!response.ok) throw new Error('Failed to delete route');
    }
};

// Employees API
export const employeesAPI = {
    getAll: async () => {
        const response = await fetch(`${API_BASE_URL}/employees`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch employees');
        return response.json();
    },

    create: async (employee) => {
        const response = await fetch(`${API_BASE_URL}/employees`, {
            method: 'POST',
            headers: getHeaders(),
            body: JSON.stringify(employee)
        });
        if (!response.ok) throw new Error('Failed to create employee');
        return response.json();
    },

    update: async (id, employee) => {
        const response = await fetch(`${API_BASE_URL}/employees/${id}`, {
            method: 'PUT',
            headers: getHeaders(),
            body: JSON.stringify(employee)
        });
        if (!response.ok) throw new Error('Failed to update employee');
        return response.json();
    },

    delete: async (id) => {
        const response = await fetch(`${API_BASE_URL}/employees/${id}`, {
            method: 'DELETE',
            headers: getHeaders()
        });
        if (!response.ok) throw new Error('Failed to delete employee');
    },

    // autoAssignZone deprecated
    // autoAssignZone: async (id) => ...
};

// Vehicles API
export const vehiclesAPI = {
    getAll: async () => {
        const response = await fetch(`${API_BASE_URL}/vehicles`, { headers: getHeaders() });
        if (!response.ok) throw new Error('Failed to fetch vehicles');
        return response.json();
    },

    create: async (vehicle) => {
        const response = await fetch(`${API_BASE_URL}/vehicles`, {
            method: 'POST',
            headers: getHeaders(),
            body: JSON.stringify(vehicle)
        });
        if (!response.ok) throw new Error('Failed to create vehicle');
        return response.json();
    },

    update: async (id, vehicle) => {
        const response = await fetch(`${API_BASE_URL}/vehicles/${id}`, {
            method: 'PUT',
            headers: getHeaders(),
            body: JSON.stringify(vehicle)
        });
        if (!response.ok) throw new Error('Failed to update vehicle');
        return response.json();
    },

    delete: async (id) => {
        const response = await fetch(`${API_BASE_URL}/vehicles/${id}`, {
            method: 'DELETE',
            headers: getHeaders()
        });
        if (!response.ok) throw new Error('Failed to delete vehicle');
    }
};
