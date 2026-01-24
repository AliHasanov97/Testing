const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
    res.json({
        message: 'Salam! API işləyir',
        status: 'success',
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

app.get('/api/test', (req, res) => {
    res.json({
        message: 'Test endpoint işləyir',
        data: {
            environment: process.env.NODE_ENV || 'development',
            nodeVersion: process.version
        }
    });
});

app.post('/api/echo', (req, res) => {
    res.json({
        message: 'Echo response',
        receivedData: req.body,
        timestamp: new Date().toISOString()
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Route tapılmadı',
        path: req.path
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server ${PORT} portunda işləyir`);
    console.log(`http://localhost:${PORT}`);
});