// const {pool} = require('../config/dbConfig');

const putOrderStatus = async (req, res) => {
  const order_id = req.params.order_id;
};

const getOrderStatus = async (req, res) => {
  res.json({
    success: true,
    controller: "order-status",
    ordersStats: {
      "completed Orders": 2,
      "yet-to-be Completed Orders": 3,
      "pending Orders": 5,
    },
  });
};

module.exports = { putOrderStatus, getOrderStatus };
