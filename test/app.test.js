const request = require('supertest');
const express = require('express');
// For testing purposes, you might export 'app' from app.js
const app = require('../src/app'); 

describe('App Security and Logic', () => {
  test('GET / should redirect to /hello/Dev (Dev Mode)', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(302);
    expect(res.headers.location).toBe('/hello/Dev');
  });

  test('XSS sanitization should escape script tags', async () => {
    const payload = "<script>alert('xss')</script>";
    const res = await request(app).get(`/hello/${encodeURIComponent(payload)}`);
    expect(res.text).toContain('&lt;script&gt;');
    expect(res.text).not.toContain('<script>');
  });

  test('Security headers (CSP) should be present', async () => {
    const res = await request(app).get('/hello/User');
    expect(res.headers).toHaveProperty('content-security-policy');
    expect(res.headers['x-frame-options']).toBe('SAMEORIGIN');
  });
});