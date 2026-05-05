const express = require('express');
const cors = require('cors');
const path = require('path');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

let lastGoodPayload = null;
const PORT = process.env.PORT || 3210;
let _server = null;

async function geocodePlace(query) {
 const url = 'https://geocoding-api.open-meteo.com/v1/search';
 const { data } = await axios.get(url, { params: { name: query, count: 1, language: 'en', format: 'json' }, timeout: 12000 });
 const r = data?.results?.[0];
 if (!r) return null;
 return { lat: r.latitude, lon: r.longitude, label: [r.name, r.admin1, r.country].filter(Boolean).join(', ') };
}

async function fetchOpenMeteo(lat, lon, days = 16) {
 const url = 'https://api.open-meteo.com/v1/forecast';
 const { data } = await axios.get(url, {
 params: {
 latitude: lat,
 longitude: lon,
 daily: 'temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,windspeed_10m_max,sunrise,sunset',
 hourly: 'temperature_2m,precipitation_probability,precipitation,windspeed_10m',
 temperature_unit: 'fahrenheit',
 windspeed_unit: 'kmh',
 precipitation_unit: 'inch',
 timezone: 'auto',
 forecast_days: Math.min(Math.max(Number(days)||16, 1), 16)
 },
 timeout: 12000
 });
 return data;
}

async function fetchNws(lat, lon) {
 try {
 const point = await axios.get(`https://api.weather.gov/points/${lat},${lon}`, { timeout: 12000 });
 const forecastUrl = point.data?.properties?.forecast;
 if (!forecastUrl) return null;
 const forecast = await axios.get(forecastUrl, { timeout: 12000 });
 return forecast.data;
 } catch {
 return null;
 }
}

function dayScore(day, prefs) {
 const rainOk = (day.precip ?? 0) <= prefs.maxPrecip;
 const windOk = (day.wind ?? 0) <= prefs.maxWind;
 const tempOk = (day.tMax ?? 999) >= prefs.minTemp && (day.tMax ?? -999) <= prefs.maxTemp;
 const score = (rainOk ? 34 : 0) + (windOk ? 33 : 0) + (tempOk ? 33 : 0);
 return { score, rainOk, windOk, tempOk, label: score >= 80 ? 'Great' : score >= 50 ? 'Fair' : 'Poor' };
}

function summarize(openMeteo, prefs = { maxPrecip: 40, maxWind: 28, minTemp: 50, maxTemp: 88 }) {
 const d = openMeteo?.daily;
 if (!d) return null;

 const days = d.time.map((date, i) => {
 const day = {
 date,
 tMax: d.temperature_2m_max?.[i],
 tMin: d.temperature_2m_min?.[i],
 precip: d.precipitation_probability_max?.[i] ?? null,
 precipAmount: d.precipitation_sum?.[i] ?? null,
 wind: d.windspeed_10m_max?.[i] ?? null,
 sunrise: d.sunrise?.[i] ?? null,
 sunset: d.sunset?.[i] ?? null
 };
 const plan = dayScore(day, prefs);
 return { ...day, plan };
 });

 const today = days[0] || null;
 const week = days.slice(0, 7);
 const month = days.slice(0, 16); // phase 1: API horizon

 const avg = (arr, key) => {
 const vals = arr.map(x => x[key]).filter(v => typeof v === 'number');
 if (!vals.length) return null;
 return Number((vals.reduce((a,b) => a+b, 0) / vals.length).toFixed(1));
 };

 return {
 today,
 week: {
 avgHigh: avg(week, 'tMax'),
 avgLow: avg(week, 'tMin'),
 avgPrecipRisk: avg(week, 'precip'),
 avgWind: avg(week, 'wind')
 },
 month: {
 avgHigh: avg(month, 'tMax'),
 avgLow: avg(month, 'tMin'),
 avgPrecipRisk: avg(month, 'precip'),
 avgWind: avg(month, 'wind')
 },
 days
 };
}

app.get('/api/weather', async (req, res) => {
 let lat = Number(req.query.lat || 40.6884); // Northampton, PA default
 let lon = Number(req.query.lon || -75.4969);
 const place = String(req.query.place || '').trim();
 const days = Number(req.query.days || 16);
 const prefs = {
 maxPrecip: Number(req.query.maxPrecip ?? 40),
 maxWind: Number(req.query.maxWind ?? 28),
 minTemp: Number(req.query.minTemp ?? 50),
 maxTemp: Number(req.query.maxTemp ?? 88)
 };

 const sourceStatus = { openMeteo: 'pending', nws: 'pending' };

 try {
 let resolvedPlace = null;
 if (place) {
 const geo = await geocodePlace(place);
 if (geo) {
 lat = geo.lat;
 lon = geo.lon;
 resolvedPlace = geo.label;
 }
 }

 const [om, nws] = await Promise.all([
 fetchOpenMeteo(lat, lon, days).then(d => { sourceStatus.openMeteo = 'ok'; return d; }).catch(() => { sourceStatus.openMeteo = 'failed'; return null; }),
 fetchNws(lat, lon).then(d => { sourceStatus.nws = d ? 'ok' : 'unavailable'; return d; }).catch(() => { sourceStatus.nws = 'failed'; return null; })
 ]);

 if (!om) return res.status(502).json({ error: 'Open-Meteo unavailable', sourceStatus });

 const payload = {
 location: { lat, lon, resolvedPlace: resolvedPlace || null },
 generatedAt: new Date().toISOString(),
 sourceStatus,
 summary: summarize(om, prefs),
 raw: {
 openMeteo: om,
 nws: nws || null
 }
 };
 lastGoodPayload = payload;
 return res.json(payload);
 } catch (err) {
 if (lastGoodPayload) {
 return res.json({ ...lastGoodPayload, stale: true, staleReason: err.message || 'fetch failed' });
 }
 return res.status(500).json({ error: err.message || 'weather fetch failed', sourceStatus });
 }
});

app.get('*', (_, res) => {
 res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

function startServer(port = PORT) {
 if (_server) return _server;
 _server = app.listen(port, () => {
 console.log(`Weather Dashboard running at http://localhost:${port}`);
 });
 return _server;
}

if (require.main === module) {
 startServer(PORT);
}

module.exports = { app, startServer };
