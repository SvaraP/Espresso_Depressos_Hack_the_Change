
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    // Basic account information
    name: {
      type: String,
      required: true,
      trim: true
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },

    passwordHash: {
      type: String,
      required: true,
      select: false
    },

    // User identity
    age: {
      type: Number,
      required: true,
      min: 13,
      max: 120
    },

    role: {
      type: String,
      required: true,
      enum: ["senior", "youth"]
    },

    // How the user wants to participate
    participationRoles: {
      type: [String],
      enum: ["mentor", "mentee", "volunteer"],
      default: []
    },

    // Matching information
    interests: {
      type: [String],
      default: []
    },

    skillsOffered: {
      type: [String],
      default: []
    },

    skillsWanted: {
      type: [String],
      default: []
    },

    goals: {
      type: [String],
      default: []
    },

    // Preferences
    activityPreference: {
      type: String,
      enum: ["low", "moderate", "high"],
      default: "moderate"
    },

    meetingPreference: {
      type: String,
      enum: ["in-person", "virtual", "both"],
      default: "both"
    },

    availability: {
      type: [String],
      default: []
    },

    location: {
      city: {
        type: String,
        trim: true,
        default: ""
      },
      area: {
        type: String,
        trim: true,
        default: ""
      }
    },

    accessibilityNeeds: {
      type: [String],
      default: []
    },

    profileCompleted: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

// Helpful index for looking up users by role
userSchema.index({ role: 1 });

const User = mongoose.model("User", userSchema);

module.exports = User;
