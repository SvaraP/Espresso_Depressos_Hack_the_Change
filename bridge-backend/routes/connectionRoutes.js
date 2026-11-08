const express = require("express");
const router = express.Router();

const protect = require("../middleware/authMiddleware");
const { getConnections } = require("../controllers/connectionController");

// Get all active connections for the logged-in user
router.get("/", protect, getConnections);

module.exports = router;