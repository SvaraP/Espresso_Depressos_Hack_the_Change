
const mongoose = require("mongoose");

const User = require("../models/user");
const Swipe = require("../models/swipe");
const Connection = require("../models/connection");

// Record a Connect or Pass action
const createSwipe = async (req, res) => {
  try {
    const { targetUserId, action } = req.body;
    const currentUserId = req.userId;

    // Validate request
    if (!targetUserId || !mongoose.Types.ObjectId.isValid(targetUserId)) {
      return res.status(400).json({
        success: false,
        message: "A valid targetUserId is required."
      });
    }

    if (!["connect", "pass"].includes(action)) {
      return res.status(400).json({
        success: false,
        message: "Action must be connect or pass."
      });
    }

    if (targetUserId === currentUserId.toString()) {
      return res.status(400).json({
        success: false,
        message: "You cannot swipe on yourself."
      });
    }

    const targetUser = await User.findById(targetUserId);

    if (!targetUser || !targetUser.profileCompleted) {
      return res.status(404).json({
        success: false,
        message: "Potential match not found."
      });
    }

    const currentUser = await User.findById(currentUserId);

    if (!currentUser) {
      return res.status(404).json({
        success: false,
        message: "Your account could not be found."
      });
    }

    if (currentUser.role === targetUser.role) {
      return res.status(400).json({
        success: false,
        message: "Bridge connections must be between a senior and a youth."
      });
    }

    // Check whether these users are already connected
    const sortedIds = [
      currentUserId.toString(),
      targetUserId.toString()
    ].sort();

    const pairKey = sortedIds.join("_");

    const existingConnection = await Connection.findOne({
      pairKey,
      status: "active"
    });

    if (existingConnection) {
      return res.status(409).json({
        success: false,
        message: "You are already connected."
      });
    }

    // Save or update the current user's swipe
    await Swipe.findOneAndUpdate(
      {
        fromUser: currentUserId,
        toUser: targetUserId
      },
      {
        $set: { action }
      },
      {
        upsert: true,
        new: true,
        runValidators: true,
        setDefaultsOnInsert: true
      }
    );

    // Passing does not create a connection
    if (action === "pass") {
      return res.status(200).json({
        success: true,
        message: "Profile passed successfully.",
        connected: false
      });
    }

    // Check whether the other user has also selected Connect
    const mutualSwipe = await Swipe.findOne({
      fromUser: targetUserId,
      toUser: currentUserId,
      action: "connect"
    });

    if (!mutualSwipe) {
      return res.status(200).json({
        success: true,
        message: "Connect request recorded. Waiting for mutual interest.",
        connected: false
      });
    }

    // Both users selected Connect: create a connection
    const connection = await Connection.findOneAndUpdate(
      { pairKey },
      {
        $setOnInsert: {
          users: sortedIds,
          pairKey,
          status: "active",
          connectedAt: new Date()
        }
      },
      {
        upsert: true,
        new: true,
        runValidators: true
      }
    );

    return res.status(201).json({
      success: true,
      message: "It's a match! You are now connected.",
      connected: true,
      connectionId: connection._id
    });

  } catch (error) {
    console.error("Swipe error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to process swipe."
    });
  }
};

module.exports = {
  createSwipe
};
