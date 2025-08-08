const { pool } = require("../config/dbConfig");

const putOrderStatus = async (req, res) => {
  // const order_id = req.params.order_id;
  let { order_id, order_status } = req.body;

  try {
    if (!order_id || !order_status) {
      return res
        .status(400)
        .json({ msg: "ERR: order_id & status are mandatory." });
    }

    const query = `SELECT * FROM public."orders" WHERE order_id = $1;`;
    const params = [order_id];
    const {
      rows: [order],
    } = await pool.query(query, params);

    const statusCheckQuery = `SELECT EXISTS ( SELECT 1 FROM unnest(enum_range(NULL::order_status)) 
      AS status WHERE status::TEXT = $1 ) AS isValid;`;

    const {
      rows: [isValid],
    } = await pool.query(statusCheckQuery, [order_status]);
    // console.log("putOrderStatus orderssss", order);
    // console.log("enum status check", isValid.isvalid);

    if (!order) {
      return res.status(400).json({ msg: "ERR: invalid order-id" });
    } else if (!isValid.isvalid) {
      return res.status(400).json({ msg: "ERR: invalid order-status" });
    }

    const insertQuery = `UPDATE public."status" SET order_status = $2 
      WHERE order_id=$1 AND order_status < $2 RETURNING *;`;
    const insertQueryParams = [order_id, order_status];
    const { rows: statusResult } = await pool.query(
      insertQuery,
      insertQueryParams
    );
    console.log("Status result", statusResult);

    if (statusResult.length === 0) {
      return res
        .status(304)
        .json({ msg: "WARN: cannot demote the order status" });
    }
    res.status(202).json({ status: "success" });
    console.log(order_id, order_status);
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error.", err: err.message });
  }
};

const getOrderStatus = async (req, res) => {
  try {
    const query = `SELECT statType AS status, COUNT(order_status) FROM public."status" AS s 
      RIGHT JOIN unnest(enum_range(NULL::order_status)) AS statType 
      ON s.order_status = statType GROUP BY statType;`;

    const { rows } = await pool.query(query);
    let orderStats = {};
    rows.map((row, _) => {
      orderStats[row.status] = row.count;
    });
    res.json({
      success: true,
      ordersStats: {
        // "completed Orders": 2,
        // "yet-to-be Completed Orders": 3,
        // "pending Orders": 5,
        ...orderStats,
      },
    });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error.", err: err.message });
  }
};

module.exports = { putOrderStatus, getOrderStatus };
