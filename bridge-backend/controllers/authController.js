
const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// Create a JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

// Remove sensitive information from user responses
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

// REGISTER
const register = async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      age,
      role
    } = req.body;

    if (!name || !email || !password || age === undefined || !role) {
      return res.status(400).json({
        success: false,
        message: "Please provide name, email, password, age, and role."
      });
    }

    if (typeof password !== "string" || password.length < 8) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 8 characters long."
      });
    }

    if (!["senior", "youth"].includes(role)) {
      return res.status(400).json({
        success: false,
        message: "Role must be senior or youth."
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const existingUser = await User.findOne({
      email: normalizedEmail
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "An account with this email already exists."
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      passwordHash,
      age,
      role
    });

    const token = generateToken(user._id.toString());

    return res.status(201).json({
      success: true,
      message: "Account created successfully.",
      token,
      user: formatUser(user)
    });
  } catch (error) {
    console.error("Registration error:", error);

    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: "An account with this email already exists."
      });
    }

    if (error.name === "ValidationError") {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    return res.status(500).json({
      success: false,
      message: "Unable to register user."
    });
  }
};

// LOGIN
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required."
      });
    }

    const user = await User.findOne({
      email: email.trim().toLowerCase()
    }).select("+passwordHash");

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password."
      });
    }

    const passwordMatches = await bcrypt.compare(
      password,
      user.passwordHash
    );

    if (!passwordMatches) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password."
      });
    }

    const token = generateToken(user._id.toString());

    return res.status(200).json({
      success: true,
      message: "Login successful.",
      token,
      user: formatUser(user)
    });
  } catch (error) {
    console.error("Login error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to log in."
    });
  }
};

// GET CURRENT USER
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found."
      });
    }

    return res.status(200).json({
      success: true,
      user: formatUser(user)
    });
  } catch (error) {
    console.error("Get current user error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve user."
    });
  }
};

module.exports = {
  register,
  login,
  getMe
};
