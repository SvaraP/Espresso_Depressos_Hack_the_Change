const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");

const Conversation = require("../models/conversation");
const Message = require("../models/message");
const Connection = require("../models/connection");

// Generate a consistent room name for each conversation
const getConversationRoom = (conversationId) => {
  return `conversation:${conversationId}`;
};

// Verify that two users still have an active connection
const hasActiveConnection = async (userId1, userId2) => {
  const connection = await Connection.findOne({
    users: { $all: [userId1, userId2] },
    status: "active"
  });

  return !!connection;
};

const initializeChatSocket = (io) => {

  // Authenticate every Socket.IO connection using the existing JWT
  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token;

      if (!token) {
        return next(new Error("Authentication required."));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      if (!decoded.userId || !mongoose.Types.ObjectId.isValid(decoded.userId)) {
        return next(new Error("Invalid authentication token."));
      }

      socket.data.userId = decoded.userId;

      next();
    } catch (error) {
      next(new Error("Invalid or expired token."));
    }
  });

  io.on("connection", (socket) => {
    const currentUserId = socket.data.userId;

    console.log(`Authenticated socket connected: ${socket.id}`);

    // Join a conversation only after checking authorization
    socket.on("join_conversation", async (data, callback) => {
      try {
        const { conversationId } = data || {};

        if (!mongoose.Types.ObjectId.isValid(conversationId)) {
          return callback?.({
            success: false,
            message: "Invalid conversation ID."
          });
        }

        const conversation = await Conversation.findOne({
          _id: conversationId,
          participants: currentUserId
        });

        if (!conversation) {
          return callback?.({
            success: false,
            message: "Conversation not found or access denied."
          });
        }

        const otherUserId = conversation.participants.find(
          (id) => id.toString() !== currentUserId.toString()
        );

        if (!otherUserId) {
          return callback?.({
            success: false,
            message: "Invalid conversation participants."
          });
        }

        const isConnected = await hasActiveConnection(
          currentUserId,
          otherUserId
        );

        if (!isConnected) {
          return callback?.({
            success: false,
            message: "You can only join chats with active connections."
          });
        }

        const room = getConversationRoom(conversationId);

        await socket.join(room);

        console.log(
          `User ${currentUserId} joined conversation ${conversationId}`
        );

        return callback?.({
          success: true,
          message: "Joined conversation successfully."
        });

      } catch (error) {
        console.error("Join conversation error:", error);

        return callback?.({
          success: false,
          message: "Failed to join conversation."
        });
      }
    });

    // Send a real-time message
    socket.on("send_message", async (data, callback) => {
      try {
        const { conversationId, text } = data || {};

        if (!mongoose.Types.ObjectId.isValid(conversationId)) {
          return callback?.({
            success: false,
            message: "Invalid conversation ID."
          });
        }

        if (!text || typeof text !== "string" || !text.trim()) {
          return callback?.({
            success: false,
            message: "Message cannot be empty."
          });
        }

        if (text.trim().length > 2000) {
          return callback?.({
            success: false,
            message: "Message cannot exceed 2000 characters."
          });
        }

        // Confirm that this user belongs to the conversation
        const conversation = await Conversation.findOne({
          _id: conversationId,
          participants: currentUserId
        });

        if (!conversation) {
          return callback?.({
            success: false,
            message: "Conversation not found or access denied."
          });
        }

        // Confirm that the other participant still has an active connection
        const otherUserId = conversation.participants.find(
          (id) => id.toString() !== currentUserId.toString()
        );

        if (!otherUserId) {
          return callback?.({
            success: false,
            message: "Invalid conversation participants."
          });
        }

        const isConnected = await hasActiveConnection(
          currentUserId,
          otherUserId
        );

        if (!isConnected) {
          return callback?.({
            success: false,
            message: "Messaging is unavailable for this connection."
          });
        }

        // Save the message to MongoDB first
        const message = await Message.create({
          conversation: conversationId,
          sender: currentUserId,
          text: text.trim(),
          readBy: [currentUserId]
        });

        // Update the conversation's latest message
        conversation.lastMessage = text.trim();
        conversation.lastMessageAt = message.createdAt;

        await conversation.save();

        // Populate sender details before broadcasting
        const populatedMessage = await Message.findById(message._id)
          .populate("sender", "name");

        const room = getConversationRoom(conversationId);

        // Deliver the message to everyone in the authorized room
        io.to(room).emit("new_message", {
          success: true,
          message: populatedMessage
        });

        console.log(
          `Message sent by ${currentUserId} in conversation ${conversationId}`
        );

        // Confirm successful delivery to the sending socket
        return callback?.({
          success: true,
          message: "Message sent successfully.",
          data: populatedMessage
        });

      } catch (error) {
        console.error("Send real-time message error:", error);

        return callback?.({
          success: false,
          message: "Failed to send message."
        });
      }
    });

    socket.on("disconnect", () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  });
};

module.exports = initializeChatSocket;