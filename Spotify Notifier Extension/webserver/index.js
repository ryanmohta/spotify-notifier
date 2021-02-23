import path from 'path';
import fs from 'fs';
import express from 'express';
import https from 'https';
import cors from 'cors';

const app = express();
app.use(cors());

var certOptions = {
  key: fs.readFileSync(path.resolve('server.key')),
  cert: fs.readFileSync(path.resolve('server.crt'))
}

app.get("/:id", (req, res) => {
  var id = req.params.id;
  res.send('hello world from ' + id);
});

https.createServer(certOptions, app).listen(8888, () => console.log("listening on port 8888"));
