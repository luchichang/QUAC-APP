const { pool } = require("../config/dbConfig");

const getDriverInfo = async (req, res) => {
  const driver_id = req.params.driver_id;
  try {
    const query = `SELECT * FROM public."drivers" WHERE driver_id = $1;`;
    const { rows } = await pool.query(query, [driver_id]);

    const status_result = await pool.query(
      `SELECT COUNT(*) AS total_order, COUNT(*) FILTER (WHERE order_status = 'completed') 
      AS completed_orders FROM public."status" WHERE driver_id = $1;`, [driver_id]
    );
    console.log("Result", status_result);

    if (rows.length === 0) {
      res.status(202).json({ msg: "No drivers found!" });
    }
    console.log(rows);
    res.json({
      success: true,
      driver_rating: rows[0].driver_rating,
      driver_tip: rows[0].earned_tip,
      driver_id,
      ...status_result.rows[0],
    });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error.", err: err.message });
  }
};

const putDriverRatingAndTip = async (req, res) => {
  const driver_id = req.params.driver_id;
  let { driver_rating, driver_tip } = req.body;

  if (!driver_id) {
    return res.status(400).json({ msg: "Missing driver_id params" });
  } else if (!driver_rating || !driver_tip) {
    return res
      .status(400)
      .json({ msg: "ERR: driver Rating & Tip are mandatory." });
  } else if (driver_rating > 5 || driver_rating < 0) {
    return res.status(400).json({
      status: "Failed",
      msg: "ERR: driver rating must between 0 - 5. ",
    });
  }
  try {
    // const drvIdQuery = `SELECT EXISTS ( SELECT 1 FROM public."drivers"
    //   WHERE driver_id = $1 ) AS isValid;`;

    const drvIdQuery = `SELECT * FROM public."drivers" WHERE driver_id = $1;`;
    const {
      rows: [driver],
    } = await pool.query(drvIdQuery, [driver_id]);

    console.log("driver Details", driver);
    if (!driver) {
      return res.status(404).json({ msg: "ERR: Invalid driver ID." });
    }
    driver_tip = Number(driver_tip) + Number(driver.earned_tip);
    driver_rating = (Number(driver_rating) + Number(driver.driver_rating)) / 2;

    driver_rating =
      driver_rating > 5 ? 5 : driver_rating < 0 ? 0 : driver_rating;

    const putQuery = `UPDATE public."drivers" SET driver_rating = $1, earned_tip = $2
      WHERE driver_id = $3 RETURNING *;`;
    const putQueryParams = [driver_rating, driver_tip, driver_id];

    const {
      rows: [updatedDriver],
    } = await pool.query(putQuery, putQueryParams);
    console.log("driver rating update:", updatedDriver);
    res.json({
      success: true,
      ...updatedDriver,
    });
  } catch (err) {
    res.status(500).json({ msg: "Internal Server Error.", err: err.message });
  }
};

module.exports = { getDriverInfo, putDriverRatingAndTip };
