import express from 'express';
const app = express();

app.get("/", (req, res) => {
  res.send('hello world');
});

app.listen(8888, () => console.log("listening on port 8888"));
