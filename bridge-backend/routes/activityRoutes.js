
const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const {
    getConnectionActivities
} = require("../controllers/activityController");

// Get physical activity recommendations for an active connection.
router.get(
    "/connections/:connectionId/activities",
    authMiddleware,
    getConnectionActivities
);

module.exports = router;
