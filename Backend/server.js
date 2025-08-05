// module Imports
const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Local file Imports
const {driverRouter} = require('./routers/driverRouter');

const app = express();

app.use(express.json());
app.use(cors());

app.use('/api', driverRouter);

app.listen(process.env.BE_PORT, (err) => {
    console.log(`Server is up and running in port ${process.env.BE_PORT}`);
})

