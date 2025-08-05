const orderRouter = require('express').Router();

const { getAllOrders, getOrderById } = require('../controllers/orderController');

orderRouter.get('/getOrders', getAllOrders);
orderRouter.get('/getOrder/:order_id', getOrderById);

module.exports = {orderRouter};