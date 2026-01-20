const express = require('express');
const helmet = require('helmet');
const app = express();

/* istanbul ignore next */
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            "default-src": ["'self'"],
            "style-src": ["'self'", "'unsafe-inline'"],
        },
    },
}));

const sanitize = (str) => {
    // If str is null/undefined, use empty string
    const input = str || ''; 
    return input.toString().replace(/[&<>"']/g, (m) => {
        const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
        return map[m];
    });
};

app.get('/', (req, res) => {
    if (process.env.NODE_ENV === 'production') {
        res.redirect('/hello/User');
    } else {
        res.redirect('/hello/Dev');
    }
});

app.get('/hello/:name', (req, res) => {
    const cleanName = sanitize(req.params.name);
    let statusColor = '#f39c12'; 
    
    if (process.env.NODE_ENV === 'production') {
        statusColor = '#27ae60'; 
    }

    res.status(200).send(`
        <!DOCTYPE html>
        <html lang="en">
            <head><meta charset="UTF-8"><title>App</title></head>
            <body style="font-family: sans-serif; text-align: center;">
                <h1>Hello, ${cleanName}!</h1>
                <p>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></p>
                <div style="background: ${statusColor}; width:10px; height:10px; margin:auto;"></div>
            </body>
        </html>
    `);
});

/* istanbul ignore next */
if (require.main === module) {
    const port = process.env.PORT || 3000;
    app.listen(port, () => console.log(`Server on ${port}`));
}

module.exports = app;