
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

connectionSchema.index(
  { users: 1 },
  { unique: true }
);

module.exports = mongoose.model(
  "Connection",
  connectionSchema
);
