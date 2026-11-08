require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const http = require("http");
const { Server } = require("socket.io");

const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const matchRoutes = require("./routes/matchRoutes");
const swipeRoutes = require("./routes/swipeRoutes");
const connectionRoutes = require("./routes/connectionRoutes");
const chatRoutes = require("./routes/chatRoutes");
const initializeChatSocket = require("./sockets/chatSocket");
const activityRoutes = require("./routes/activityRoutes");

const app = express();

// Create the HTTP server
const server = http.createServer(app);

// Attach Socket.IO to the HTTP server
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Connect to MongoDB
connectDB();

// Security and request middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Authentication routes
app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/users", userRoutes);
app.use("/api/v1/matches", matchRoutes);
app.use("/api/v1/swipes", swipeRoutes);
app.use("/api/v1/connections", connectionRoutes);
app.use("/api/v1/chat", chatRoutes);
app.use("/api/v1", activityRoutes);

// Health check endpoint
app.get("/api/v1/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Bridge API is running!",
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    message: "Welcome to the Bridge API"
  });
});

initializeChatSocket(io);

// Start the HTTP and Socket.IO server
const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Bridge server running on port ${PORT}`);
});