
const mongoose = require("mongoose");
const Connection = require("../models/connection");
const {
    getSharedActivityRecommendations
} = require("../services/activityRecommendationService");

/**
 * Get physical activity recommendations for an active connection.
 *
 * Only members of the connection can access its recommendations.
 */
async function getConnectionActivities(req, res) {
    try {
        const { connectionId } = req.params;

        // Validate the connection ID.
        if (!mongoose.Types.ObjectId.isValid(connectionId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid connection ID."
            });
        }

        // Find an active connection that includes the requesting user.
        const connection = await Connection.findOne({
            _id: connectionId,
            users: req.userId,
            status: "active"
        }).populate(
            "users",
            "name age role activityPreference"
        );

        // Do not reveal whether an inaccessible connection exists.
        if (!connection) {
            return res.status(404).json({
                success: false,
                message: "Active connection not found."
            });
        }

        if (!connection.users || connection.users.length !== 2) {
            return res.status(500).json({
                success: false,
                message: "Unable to retrieve connection participants."
            });
        }

        // Generate recommendations for both connected users.
        const result = await getSharedActivityRecommendations(
            connection.users[0],
            connection.users[1]
        );

        return res.status(200).json({
            success: true,
            connectionId: connection._id,
            ...result
        });

    } catch (error) {
        console.error("Get connection activities error:", error.message);

        // The external activity-data source may be unavailable.
        if (
            error.message.includes("OpenActive") ||
            error.message.includes("Unable to retrieve")
        ) {
            return res.status(503).json({
                success: false,
                message: "Activity recommendations are temporarily unavailable."
            });
        }

        return res.status(500).json({
            success: false,
            message: "Unable to retrieve activity recommendations."
        });
    }
}

module.exports = {
    getConnectionActivities
};
