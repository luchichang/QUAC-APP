// const {pool} = require('../config/dbConfig');

const getDriverInfo = async (req, res) => {
  const driver_id = req.params.driver_id;

  res.json({ success: true, con: "driver Controller", driver_id });
};

const putDriverRatingAndTip = async (req, res) => {
  const driver_id = req.params.driver_id;
  const { driver_rating, driver_tip } = req.body;

  if (!driver_id) {
    res.status(400).json({msg: 'Missing driver_id params'});
  } else if (!driver_rating || !driver_tip) {
    res.status(400).json({msg: "ERR: missing body"});
  }

  res.json({
    success: true,
    controller: "Driver Con",
    params: driver_id,
    req_body: { rating: driver_rating, tip: driver_tip },
  });
};

module.exports = { getDriverInfo, putDriverRatingAndTip };
