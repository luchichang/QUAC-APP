const express = require('express');

const driverRouter = express.Router();

driverRouter.get('/getDriverDetails',(req,res)=> res.json({success: 'ok'}));

module.exports = {driverRouter};