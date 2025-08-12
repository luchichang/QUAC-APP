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
    const {
      rows: [order],
    } = await pool.query(query, params);
    // console.log("getOrderById result", result);

    if (!order) {
      return res.status(202).json({ msg: "no order found" });
    }
    const ordQuery = `SELECT user_id FROM public."status" WHERE order_id = $1;`;

    const {
      rows: [ {user_id} ],
    } = await pool.query(ordQuery, params);
    console.log('user id',user_id);

    const usrQuery = `SELECT * FROM public."users" WHERE user_id=$1`;

    const {
      rows: [user],
    } = await pool.query(usrQuery, [user_id]);
    console.log("user",user);

    res.json({
      success: true,
      order: {...order},
      user: {...user},
    });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error", err: err.message });
  }
};

// controller returns all the orders location
const retriveOrdersLocation = async (req, res) => {
  try{
    const query = `SELECT s.order_id, u.user_address -> 'latitude' AS Latitude,
      u.user_address-> 'longitude' AS Longitude FROM public."users" AS u
      JOIN public."status" AS s ON u.user_id = s.user_id`;
    const {rows: locCoordinates} = await pool.query(query);

    // console.log(result);
    res.json({success: true, locationCoordinates: locCoordinates});
  }catch(err){
    res.status(500).json({msg: "Internal Server Error.", err: err.message});
  }
  // res.json({ success: true });
};

module.exports = { getAllOrders, getOrderById, retriveOrdersLocation };
