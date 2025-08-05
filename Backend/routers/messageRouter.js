const express = require('express');

const messageRouter = express.Router();

messageRouter.get('/sendSms',(req, res)=> res.json({success: true}));

module.exports = {messageRouter};