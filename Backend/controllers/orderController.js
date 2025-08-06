// for accessing the DB
const { pool } = require("../config/dbConfig");

// sends all the order details
const getAllOrders = async (req, res) => {
  try {
    query = `SELECT * FROM public."orders";`;
    const { rows: orders } = await pool.query(query);
    // console.log(result.rows.length);
    // console.log(result);
    res.json({
      success: true,
      TotalOrders: orders.length,
      //   Orders: [...orders],
      Orders: orders,
    });
  } catch (err) {
    res.status(500).json({ msg: "Internal server error", error: err.message });
  }
};

const getOrderById = async (req, res) => {
  const order_id = req.params.order_id;

  try {
    const query = `SELECT * FROM public."orders" WHERE order_id = $1`;
    const params = [order_id];
    const result = await pool.query(query, params);
    console.log("getOrderById result", result);

    if (result.rows.length === 0) {
      res.status(202).json({ msg: "no order found" });
    }

    res.json({
      success: true,
      order: result.rows[0],
    });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error", err: err.message });
  }
};

// controller returns all the orders location
const retriveOrdersLocation = async (req, res) => {
  res.json({ success: true });
};

module.exports = { getAllOrders, getOrderById, retriveOrdersLocation };
