
const mongoose = require("mongoose");

const swipeSchema = new mongoose.Schema(
  {
    fromUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    toUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    action: {
      type: String,
      enum: ["connect", "pass"],
      required: true
    }
  },
  {
    timestamps: true
  }
);

// One swipe per user pair, in each direction
swipeSchema.index(
  { fromUser: 1, toUser: 1 },
  { unique: true }
);

module.exports = mongoose.model("Swipe", swipeSchema);
