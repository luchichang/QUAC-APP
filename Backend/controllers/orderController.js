// for accessing the DB
// const {pool} = require('../config/dbConfig');

const getAllOrders = async (req, res) => {
    res.json({success: true, controller: 'getAllOrders'});
};


const getOrderById = async (req, res) => {
    const order_id = req.params.order_id; 

    if(order_id > 100){
        res.send("no order");
    }
    res.json({ success: true, controller: 'getOrderById', order_id: order_id });
};

module.exports = {getAllOrders, getOrderById };
