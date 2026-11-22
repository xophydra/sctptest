const http=require('http'),fs=require('fs');
const body=fs.readFileSync('/eyes.txt','utf8');
http.createServer((q,r)=>{
  if(q.url==='/api/health'){r.writeHead(200,{'content-type':'application/json'});r.end('{"status":"ok"}');return;}
  r.writeHead(200,{'content-type':'text/plain'});r.end(body);
}).listen(3000);
