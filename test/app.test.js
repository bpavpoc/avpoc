const request = require('supertest');
const app = require('../src/app');

describe('Comprehensive Branch Testing', () => {
    
    // Test Path A: Dev Environment logic
    test('Redirects to /hello/Dev in default/dev mode', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toBe(302);
        expect(res.headers.location).toBe('/hello/Dev');
    });

    // Test Path B: Production Environment logic (Forces the other side of the ternary)
    test('Redirects to /hello/User when NODE_ENV is production', async () => {
        process.env.NODE_ENV = 'production';
        const res = await request(app).get('/');
        expect(res.statusCode).toBe(302);
        expect(res.headers.location).toBe('/hello/User');
        // Reset env after test
        process.env.NODE_ENV = 'test'; 
    });

    test('Sanitizes complex XSS and handles normal names', async () => {
        const res = await request(app).get('/hello/John&Doe');
        expect(res.text).toContain('John&amp;Doe');
    });

    // Test Path C: The "Empty Name" branch in sanitize helper
    test('Sanitize helper handles empty input', async () => {
        // We can test this by calling a route that might result in an empty param 
        // or by ensuring our helper logic is robust
        const res = await request(app).get('/hello/%20'); // Space character
        expect(res.statusCode).toBe(200);
    });
});