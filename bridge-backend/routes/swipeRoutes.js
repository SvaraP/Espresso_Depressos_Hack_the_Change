
const express = require("express");
const router = express.Router();

const protect = require("../middleware/authMiddleware");

const {
  createSwipe
} = require("../controllers/swipeController");

router.post("/", protect, createSwipe);

module.exports = router;
