
const {
  getRankedMatches
} = require("../services/matchingService");

const getMatches = async (req, res) => {
  try {
    const page = Math.max(
      1,
      parseInt(req.query.page, 10) || 1
    );

    const limit = Math.min(
      50,
      Math.max(1, parseInt(req.query.limit, 10) || 10)
    );

    const result = await getRankedMatches(
      req.userId,
      page,
      limit
    );

    return res.status(200).json({
      success: true,
      ...result
    });
  } catch (error) {
    console.error("Matching error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve potential matches."
    });
  }
};

module.exports = {
  getMatches
};
