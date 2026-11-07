
const User = require("../models/User");

// Fields users are allowed to update themselves
const allowedFields = [
  "name",
  "age",
  "participationRoles",
  "interests",
  "skillsOffered",
  "skillsWanted",
  "goals",
  "activityPreference",
  "meetingPreference",
  "availability",
  "location",
  "accessibilityNeeds"
];

const formatUser = (user) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  age: user.age,
  role: user.role,
  participationRoles: user.participationRoles,
  interests: user.interests,
  skillsOffered: user.skillsOffered,
  skillsWanted: user.skillsWanted,
  goals: user.goals,
  activityPreference: user.activityPreference,
  meetingPreference: user.meetingPreference,
  availability: user.availability,
  location: user.location,
  accessibilityNeeds: user.accessibilityNeeds,
  profileCompleted: user.profileCompleted
});

// GET MY PROFILE
const getMyProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found."
      });
    }

    res.status(200).json({
      success: true,
      user: formatUser(user)
    });
  } catch (error) {
    console.error("Get profile error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to retrieve profile."
    });
  }
};

// UPDATE MY PROFILE
const updateMyProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found."
      });
    }

    // Only accept fields explicitly allowed above
    for (const field of allowedFields) {
      if (Object.prototype.hasOwnProperty.call(req.body, field)) {
        user[field] = req.body[field];
      }
    }

    // Check whether the essential onboarding fields are filled
    user.profileCompleted = Boolean(
      user.name &&
      user.age &&
      user.interests.length > 0 &&
      user.goals.length > 0 &&
      user.participationRoles.length > 0
    );

    await user.save();

    res.status(200).json({
      success: true,
      message: "Profile updated successfully.",
      user: formatUser(user)
    });
  } catch (error) {
    console.error("Update profile error:", error);

    if (error.name === "ValidationError") {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    res.status(500).json({
      success: false,
      message: "Unable to update profile."
    });
  }
};

module.exports = {
  getMyProfile,
  updateMyProfile
};
