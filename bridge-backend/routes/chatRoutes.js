const express = require("express");
const router = express.Router();

const protect = require("../middleware/authMiddleware");

const {
  getOrCreateConversation,
  sendMessage,
  getMessages,
  getConversations
} = require("../controllers/chatController");

// Get all conversations for the logged-in user
router.get("/", protect, getConversations);

// Create or retrieve a conversation with a connection
router.post("/conversation", protect, getOrCreateConversation);

// Send a message
router.post("/message", protect, sendMessage);

// Retrieve messages in a conversation
router.get("/:conversationId/messages", protect, getMessages);

module.exports = router;