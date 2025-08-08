const { pool } = require("../config/dbConfig");

const getDriverInfo = async (req, res) => {
  const driver_id = req.params.driver_id;
  try {
    const query = `SELECT * FROM public."drivers" WHERE driver_id = $1;`;
    const {rows} = await pool.query(query, [driver_id]);

    const status_result = await pool.query(`SELECT COUNT(*) AS totalOrder, COUNT(*) FILTER (WHERE order_status = 'completed') AS completedOrders FROM public."status";`);
    console.log("Result", status_result);

    if(rows.length === 0){
      res.status(202).json({msg: "No drivers found!"});
    }
    console.log(rows);
    res.json({ success: true, driver_rating: rows[0].driver_rating, driver_tip: rows[0].driver_tip, driver_id , ... status_result.rows[0] });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error.", err: err.message });
  }
};

const putDriverRatingAndTip = async (req, res) => {
  const driver_id = req.params.driver_id;
  const { driver_rating, driver_tip } = req.body;

  if (!driver_id) {
    res.status(400).json({ msg: "Missing driver_id params" });
  } else if (!driver_rating || !driver_tip) {
    res.status(400).json({ msg: "ERR: missing body" });
  }

  res.json({
    success: true,
    controller: "Driver Con",
    params: driver_id,
    req_body: { rating: driver_rating, tip: driver_tip },
  });
};

module.exports = { getDriverInfo, putDriverRatingAndTip };
