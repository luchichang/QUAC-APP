const express = require('express');

const driverRouter = express.Router();

const {getDriverInfo, putDriverRatingAndTip, singleOrderRatingAndTip} = require('../controllers/driverController');

driverRouter.get('/driverDashboard/:driver_id', getDriverInfo);
driverRouter.put('/putDriverRatingAndTip/:driver_id', putDriverRatingAndTip);
driverRouter.get('/getRatingAndTip/:order_id', singleOrderRatingAndTip);


module.exports = {driverRouter};