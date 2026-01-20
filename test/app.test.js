const request = require('supertest');

describe('Final Coverage Push', () => {
    beforeEach(() => {
        jest.resetModules();
    });

    test('Path 1: Production Redirect (if)', async () => {
        process.env.NODE_ENV = 'production';
        const app = require('../src/app');
        const res = await request(app).get('/');
        expect(res.header.location).toBe('/hello/User');
    });

    test('Path 2: Development Redirect (else)', async () => {
        process.env.NODE_ENV = 'development';
        const app = require('../src/app');
        const res = await request(app).get('/');
        expect(res.header.location).toBe('/hello/Dev');
    });

    test('Path 3: Sanitizer and Production Color', async () => {
        process.env.NODE_ENV = 'production';
        const app = require('../src/app');
        const res = await request(app).get('/hello/' + encodeURIComponent('<script>'));
        expect(res.text).toContain('&lt;script&gt;');
        expect(res.text).toContain('#27ae60'); // Prod Color
    });

    test('Path 4: Sanitizer Fallback and Dev Color', async () => {
        process.env.NODE_ENV = 'development';
        const app = require('../src/app');
        const res = await request(app).get('/hello/tester');
        expect(res.text).toContain('#f39c12'); // Dev Color
    });
});