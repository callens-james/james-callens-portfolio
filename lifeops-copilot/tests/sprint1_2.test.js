const http=require('http');
function get(p){return new Promise((res,rej)=>http.get('http://127.0.0.1:3360'+p,r=>{let d='';r.on('data',c=>d+=c);r.on('end',()=>res({s:r.statusCode,d}));}).on('error',rej));}
(async()=>{for(const p of ['/api/health','/api/items','/api/model/check?model=phi3:mini','/api/brief/weekly','/api/export/items.csv']){const r=await get(p); if(r.s!==200){console.error('FAIL',p,r.s); process.exit(1);} console.log('OK',p);} console.log('PASS sprint1.2');})();
