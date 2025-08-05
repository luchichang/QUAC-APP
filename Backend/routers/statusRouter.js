const statusRouter = require('express').Router();

const {getOrderStatus, putOrderStatus} = require('../controllers/statusController');

statusRouter.put('/updateOrderStatus/:order_id', putOrderStatus );
statusRouter.get('/getOrdersStatus', getOrderStatus);

module.exports = {statusRouter};