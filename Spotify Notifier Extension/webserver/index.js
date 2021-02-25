import path from 'path';
import fs from 'fs';
import express from 'express';
import https from 'https';
import cors from 'cors';
import request from 'request';
import bodyParser from 'body-parser';

const app = express();
app.use(cors());
// app.use(express.static("public"));
// app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

var data = {};

var certOptions = {
  key: fs.readFileSync(path.resolve('server.key')),
  cert: fs.readFileSync(path.resolve('server.crt'))
};

// app.get("/:id", (req, res) => {
//   var id = decodeURIComponent(req.params.id);
//   console.log(id);

  // download(id, `public/images/${imageFileName(id)}.jpeg`, function(){
  //   res.send('hello world from ' + id + ed);
  // });

  // res.send('hello world from ' + id);
  //
  // function imageFileName(url) {
  //   const startingIndex = url.indexOf('/image/') + 7;
  //   return url.substring(startingIndex);
  // }


// });

// app.get('/song/:title/:artist/:albumURL', function(req, res, next) {
//   console.log(req.params.title);
//   console.log(req.params.artist);
//   console.log(req.params.albumURL);
//
//   console.log(decodeURIComponent(req.params.title));
//   console.log(decodeURIComponent(req.params.artist));
//   console.log(decodeURIComponent(req.params.albumURL));
//
//   data = {
//     "title": decodeURIComponent(req.params.title),
//     "artist": decodeURIComponent(req.params.artist),
//     "albumURL": decodeURIComponent(req.params.albumURL)
//   };
//
//   res.send(req.params.title);
// });

app.post('/update', (req, res) => {
  //code to perform particular action.
  //To access POST variable use req.body()methods.
  data = req.body;
  console.log(data);
  res.status(200);
});

app.get('/latest', (req, res) => {
  res.json(data);
})

// function download(uri, filename, callback) {
//   request.head(uri, function(err, res, body){
//     console.log('content-type:', res.headers['content-type']);
//     console.log('content-length:', res.headers['content-length']);
//
//     request(uri).pipe(fs.createWriteStream(filename)).on('close', callback);
//   });
// }

https.createServer(certOptions, app).listen(8888, () => console.log("https server listening on port 8888"));
// app.listen(8080, () => console.log(`Started server at http://localhost:8080!`));
