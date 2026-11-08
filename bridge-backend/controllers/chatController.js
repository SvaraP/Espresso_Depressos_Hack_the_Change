const mongoose = require("mongoose");

const Conversation = require("../models/conversation");
const Message = require("../models/message");
const Connection = require("../models/connection");

// Helper: Generate a consistent ID for a pair of users
const createPairKey = (userId1, userId2) => {
  return [userId1.toString(), userId2.toString()]
    .sort()
    .join("_");
};

// Helper: Check whether two users have an active connection
const hasActiveConnection = async (userId1, userId2) => {
  const connection = await Connection.findOne({
    users: { $all: [userId1, userId2] },
    status: "active"
  });

  return !!connection;
};

// Create or retrieve a conversation
const getOrCreateConversation = async (req, res) => {
  try {
    const { targetUserId } = req.body;
    const currentUserId = req.userId;

    if (!mongoose.Types.ObjectId.isValid(targetUserId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid user ID."
      });
    }

    if (targetUserId === currentUserId.toString()) {
      return res.status(400).json({
        success: false,
        message: "You cannot start a conversation with yourself."
      });
    }

    const isConnected = await hasActiveConnection(
      currentUserId,
      targetUserId
    );

    if (!isConnected) {
      return res.status(403).json({
        success: false,
        message: "You can only chat with your active connections."
      });
    }

    const pairKey = createPairKey(currentUserId, targetUserId);

    const conversation = await Conversation.findOneAndUpdate(
      { pairKey },
      {
        $setOnInsert: {
          participants: [currentUserId, targetUserId],
          pairKey
        }
      },
      {
        new: true,
        upsert: true,
        runValidators: true
      }
    ).populate("participants", "name age role");

    return res.status(200).json({
      success: true,
      message: "Conversation retrieved successfully.",
      conversation
    });
  } catch (error) {
    console.error("Create conversation error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create conversation."
    });
  }
};

// Send a message
const sendMessage = async (req, res) => {
  try {
    const { conversationId, text } = req.body;
    const currentUserId = req.userId;

    if (!mongoose.Types.ObjectId.isValid(conversationId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid conversation ID."
      });
    }

    if (!text || typeof text !== "string" || !text.trim()) {
      return res.status(400).json({
        success: false,
        message: "Message cannot be empty."
      });
    }

    if (text.trim().length > 2000) {
      return res.status(400).json({
        success: false,
        message: "Message cannot exceed 2000 characters."
      });
    }

    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: currentUserId
    });

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found."
      });
    }

    const otherUserId = conversation.participants.find(
      (id) => id.toString() !== currentUserId.toString()
    );

    const isConnected = await hasActiveConnection(
      currentUserId,
      otherUserId
    );

    if (!isConnected) {
      return res.status(403).json({
        success: false,
        message: "Messaging is unavailable for this connection."
      });
    }

    const message = await Message.create({
      conversation: conversationId,
      sender: currentUserId,
      text: text.trim(),
      readBy: [currentUserId]
    });

    conversation.lastMessage = text.trim();
    conversation.lastMessageAt = message.createdAt;
    await conversation.save();

    return res.status(201).json({
      success: true,
      message: "Message sent successfully.",
      data: message
    });
  } catch (error) {
    console.error("Send message error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to send message."
    });
  }
};

// Retrieve messages in a conversation
const getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const currentUserId = req.userId;

    if (!mongoose.Types.ObjectId.isValid(conversationId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid conversation ID."
      });
    }

    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: currentUserId
    });

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found."
      });
    }

    const otherUserId = conversation.participants.find(
      (id) => id.toString() !== currentUserId.toString()
    );

    const isConnected = await hasActiveConnection(
      currentUserId,
      otherUserId
    );

    if (!isConnected) {
      return res.status(403).json({
        success: false,
        message: "Chat history is unavailable for this connection."
      });
    }

    const messages = await Message.find({
      conversation: conversationId
    })
      .populate("sender", "name")
      .sort({ createdAt: 1 });

    return res.status(200).json({
      success: true,
      count: messages.length,
      messages
    });
  } catch (error) {
    console.error("Get messages error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to retrieve messages."
    });
  }
};

// Retrieve all conversations for the logged-in user
const getConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.userId
    })
      .populate("participants", "name age role")
      .sort({ lastMessageAt: -1, updatedAt: -1 });

    const formattedConversations = conversations.map((conversation) => {
      const otherUser = conversation.participants.find(
        (user) => user._id.toString() !== req.userId.toString()
      );

      return {
        conversationId: conversation._id,
        user: otherUser,
        lastMessage: conversation.lastMessage,
        lastMessageAt: conversation.lastMessageAt
      };
    });

    return res.status(200).json({
      success: true,
      count: formattedConversations.length,
      conversations: formattedConversations
    });
  } catch (error) {
    console.error("Get conversations error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to retrieve conversations."
    });
  }
};

module.exports = {
  getOrCreateConversation,
  sendMessage,
  getMessages,
  getConversations
};