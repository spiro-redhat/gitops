'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';
const TOKEN = process.env.TOKEN || "No idea";

// App
const app = express();

app.get('/', (req, res) => {
  res.send('Your token is ' + TOKEN);
});

app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT} with TOKEN`);
});