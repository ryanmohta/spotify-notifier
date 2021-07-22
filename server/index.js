const DEVELOPMENT = false;

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

if (DEVELOPMENT) {
  var certOptions = {
    key: fs.readFileSync(path.resolve('server.key')),
    cert: fs.readFileSync(path.resolve('server.crt'))
  };
}

app.post('/update', (req, res) => {
  data = req.body;
  res.sendStatus(200);
});

app.get('/latest', (req, res) => {
  res.json(data);
})

if (DEVELOPMENT) {
  https.createServer(certOptions, app).listen(8888, () => console.log("https server listening on port 8888"));
}
else {
  app.listen(process.env.PORT || 8888, () => console.log(`listening on port ${process.env.PORT || 8888}`));
}
