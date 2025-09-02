const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', async (req, res) => {
  res.send({ message: 'Pi Credit App — Hello from Node.js!', env: process.env.NODE_ENV || 'staging' });
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
