import http from 'http'
import fs from 'fs'


export const server = http.createServer((req, res) => {

  const filePath = "/home/core/mentee_domain.txt"

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.statusCode = 500;
      res.setHeader('Content-Type', 'text/plain');
      res.end('Internal Server Error\n');
      return;
    }

    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end(data);
  });
});


export function serverClose () {
  server.close((err)=>{
    if (err) {
      console.error('Error terminating server:', err);
    } else {
      console.log('Server terminated.');
    }
    process.exit(err ? 1 : 0);
  })
}
  