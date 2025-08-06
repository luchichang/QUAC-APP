const orderRouter = require('express').Router();

const { getAllOrders, getOrderById, retriveOrdersLocation } = require('../controllers/orderController');

orderRouter.get('/getOrders', getAllOrders);
orderRouter.get('/getOrder/:order_id', getOrderById);
orderRouter.get('/getOrdersLocation', retriveOrdersLocation)

module.exports = {orderRouter};