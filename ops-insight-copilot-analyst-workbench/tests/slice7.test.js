const http = require('http');

function get(path) {
 return new Promise((resolve, reject) => {
 http.get(`http://127.0.0.1:3350${path}`, (res) => {
 let data = '';
 res.on('data', c => data += c);
 res.on('end', () => resolve({ status: res.statusCode, data, headers: res.headers }));
 }).on('error', reject);
 });
}

(async () => {
 const checks = [
 ['/api/health', 200],
 ['/api/kpis', 200],
 ['/api/anomalies', 200],
 ['/api/recommendations', 200],
 ['/api/audit', 200],
 ['/api/brief/weekly', 200],
 ['/api/export/kpis.csv', 200],
 ['/api/export/recommendations.csv', 200]
 ];

 for (const [path, expected] of checks) {
 const r = await get(path);
 if (r.status !== expected) {
 console.error(`FAIL ${path}: expected ${expected}, got ${r.status}`);
 process.exit(1);
 }
 console.log(`OK ${path}`);
 }

 console.log('slice7 test pack: PASS');
})();
