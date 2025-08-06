const express = require('express');

const driverRouter = express.Router();

const {getDriverInfo, putDriverRatingAndTip} = require('../controllers/driverController');

driverRouter.get('/driverDashboard/:driver_id', getDriverInfo);
driverRouter.put('/putDriverRatingAndTip/:driver_id', putDriverRatingAndTip)

module.exports = {driverRouter};