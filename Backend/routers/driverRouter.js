const express = require('express');

const driverRouter = express.Router();

const {getDriverInfo, putDriverRatingAndTip} = require('../controllers/driverController');

driverRouter.get('/getDriverDetails/:driver_id', getDriverInfo);
driverRouter.put('/putDriverRatingAndTip', putDriverRatingAndTip)

module.exports = {driverRouter};