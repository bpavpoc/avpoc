const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

// --- IMPROVED DEBUG LOGGING ---
if (ENV === 'development') {
    app.use((req, res, next) => {
        const now = new Date().toISOString();
        // Adding a separator and ensuring the log is explicit
        console.log(`\n[DEBUG] ${now}`);
        console.log(` > Request: ${req.method} ${req.url}`);
        console.log(` > Remote IP: ${req.ip}`);
        next();
    });
}

// Redirect root
app.get('/', (req, res) => {
    const defaultName = (ENV === 'production') ? 'User' : 'Dev';
    res.redirect(`/hello/${defaultName}`);
});

// Hello route
app.get('/hello/:name', (req, res) => {
    const name = req.params.name;
    const statusColor = ENV === 'production' ? '#27ae60' : '#f39c12';

    res.status(200).send(`
        <html>
            <body style="font-family: sans-serif; text-align: center; padding-top: 50px;">
                <h1 style="color: #2c3e50;">Hello, ${name}!</h1>
                <p>Environment: <strong style="color: ${statusColor};">${ENV}</strong></p>
            </body>
        </html>
    `);
});

app.listen(PORT, () => {
    // Force a clear start log
    process.stdout.write(`\n--- Server Started in ${ENV} mode on Port ${PORT} ---\n`);
});