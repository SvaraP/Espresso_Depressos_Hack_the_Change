
const mongoose = require("mongoose");

const connectionSchema = new mongoose.Schema(
  {
    users: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
      }
    ],

    // Sorted user IDs create a consistent unique identifier for each pair
    pairKey: {
      type: String,
      required: true,
      unique: true
    },

    status: {
      type: String,
      enum: ["active", "ended"],
      default: "active"
    },

    connectedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

connectionSchema.index({ users: 1 });

const Connection = mongoose.models.Connection || mongoose.model("Connection", connectionSchema);

module.exports = Connection;
