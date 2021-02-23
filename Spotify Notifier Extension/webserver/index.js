import path from 'path';
import fs from 'fs';
import express from 'express';
import https from 'https';

const app = express();

var certOptions = {
  key: fs.readFileSync(path.resolve('server.key')),
  cert: fs.readFileSync(path.resolve('server.crt'))
}

app.get("/:id", (req, res) => {
  var id = req.params.id;
  // res.send('hello world from ' + id);
  return 'helloooo from ' + id;
});

https.createServer(certOptions, app).listen(8888, () => console.log("listening on port 8888"));
