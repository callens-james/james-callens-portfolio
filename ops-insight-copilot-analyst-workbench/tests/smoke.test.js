const http = require('http');
http.get('http://127.0.0.1:3350/api/health', res => {
 if (res.statusCode !== 200) process.exit(1);
 console.log('smoke ok');
}).on('error', () => process.exit(1));
