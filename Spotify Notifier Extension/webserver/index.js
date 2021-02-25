import path from 'path';
import fs from 'fs';
import express from 'express';
import https from 'https';
import cors from 'cors';
import bodyParser from 'body-parser';

const app = express();
app.use(cors());
app.use(bodyParser.json());

var data = {};

var certOptions = {
  key: fs.readFileSync(path.resolve('server.key')),
  cert: fs.readFileSync(path.resolve('server.crt'))
};

app.post('/update', (req, res) => {
  data = req.body;
  console.log(data);
  res.status(200);
});

app.get('/latest', (req, res) => {
  res.json(data);
})

https.createServer(certOptions, app).listen(8888, () => console.log("https server listening on port 8888"));
