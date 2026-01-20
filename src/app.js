const express = require('express');
const helmet = require('helmet');
const app = express();

const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

// 1. Add Security Headers & CSP
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            "default-src": ["'self'"],
            "script-src": ["'self'"], // Disallows inline scripts
            "style-src": ["'self'", "'unsafe-inline'"], // Allows our inline styles
            "img-src": ["'self'", "data:"],
            "upgrade-insecure-requests": [],
        },
    },
}));

// 2. XSS Sanitization Helper
const sanitize = (str) => {
    return str.replace(/[&<>"']/g, (m) => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
    })[m]);
};

if (ENV === 'development') {
    app.use((req, res, next) => {
        console.log(`[DEBUG] ${new Date().toISOString()} | ${req.method} ${req.url}`);
        next();
    });
}

app.get('/', (req, res) => {
    const defaultName = (ENV === 'production') ? 'User' : 'Dev';
    res.redirect(`/hello/${defaultName}`);
});

app.get('/hello/:name', (req, res) => {
    const cleanName = sanitize(req.params.name);
    const statusColor = ENV === 'production' ? '#27ae60' : '#f39c12';

    res.status(200).send(`
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="UTF-8">
                <title>Hello App</title>
            </head>
            <body style="font-family: sans-serif; text-align: center; padding-top: 50px;">
                <h1 style="color: #2c3e50;">Hello, ${cleanName}!</h1>
                <p>Environment: <strong style="color: ${statusColor};">${ENV}</strong></p>
            </body>
        </html>
    `);
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT} in ${ENV} mode`);
});