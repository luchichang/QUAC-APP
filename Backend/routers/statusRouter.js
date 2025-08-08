const statusRouter = require('express').Router();

const {getOrderStatus, putOrderStatus} = require('../controllers/statusController');

statusRouter.put('/updateOrderStatus', putOrderStatus );
statusRouter.get('/getOrdersStatus', getOrderStatus);

module.exports = {statusRouter};