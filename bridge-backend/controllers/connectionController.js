const Connection = require("../models/connection");

const getConnections = async (req, res) => {
  try {
    const connections = await Connection.find({
      users: req.userId,
      status: "active"
    })
      .populate("users", "name age role interests location")
      .sort({ connectedAt: -1 });

    const formattedConnections = connections.map((connection) => {
      const otherUser = connection.users.find(
        (user) => user._id.toString() !== req.userId.toString()
      );

      return {
        connectionId: connection._id,
        connectedAt: connection.connectedAt,
        user: otherUser
      };
    });

    return res.status(200).json({
      success: true,
      count: formattedConnections.length,
      connections: formattedConnections
    });
  } catch (error) {
    console.error("Get connections error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to retrieve connections."
    });
  }
};

module.exports = { getConnections };