const { app, BrowserWindow } = require('electron');
const path = require('path');
const http = require('http');

let serverInstance = null;

function waitForServer(url, timeoutMs = 15000) {
 const started = Date.now();
 return new Promise((resolve, reject) => {
 const tryOnce = () => {
 const req = http.get(url, (res) => {
 res.resume();
 resolve(true);
 });
 req.on('error', () => {
 if (Date.now() - started > timeoutMs) return reject(new Error('Server startup timeout'));
 setTimeout(tryOnce, 300);
 });
 req.setTimeout(2000, () => req.destroy());
 };
 tryOnce();
 });
}

function startLocalServer() {
 if (serverInstance) return;
 const { startServer } = require(path.join(__dirname, '..', 'server.js'));
 serverInstance = startServer(3210);
}

async function createWindow() {
 startLocalServer();
 await waitForServer('http://127.0.0.1:3210', 20000);

 const win = new BrowserWindow({
 width: 1280,
 height: 860,
 autoHideMenuBar: true,
 icon: path.join(__dirname, '..', 'assets', 'weather-icon.svg'),
 webPreferences: {
 contextIsolation: true,
 nodeIntegration: false
 }
 });

 win.loadURL('http://127.0.0.1:3210');
}

app.whenReady().then(async () => {
 try { await createWindow(); }
 catch {
 const win = new BrowserWindow({ width: 900, height: 600, autoHideMenuBar: true });
 win.loadURL('data:text/plain,Weather Dashboard failed to start local service.');
 }

 app.on('activate', () => {
 if (BrowserWindow.getAllWindows().length === 0) createWindow();
 });
});

app.on('window-all-closed', () => {
 if (serverInstance) {
 try { serverInstance.close(); } catch {}
 }
 if (process.platform !== 'darwin') app.quit();
});
