
const { io } = require("socket.io-client");

const SERVER_URL = "http://localhost:5000";

const CONVERSATION_ID = "6aefd482067f42dec491ab42";

const ALEX_TOKEN = process.env.ALEX_TOKEN;
const JORDAN_TOKEN = process.env.JORDAN_TOKEN;

const TEST_MESSAGE =
  "Hey Jordan! This is a real-time Socket.IO test. Can you see this immediately?";

const connectSocket = (name, token) => {
  return new Promise((resolve, reject) => {
    const socket = io(SERVER_URL, {
      auth: { token },
      reconnection: false,
      timeout: 5000
    });

    socket.once("connect", () => {
      console.log(`${name} connected: ${socket.id}`);
      resolve(socket);
    });

    socket.once("connect_error", (error) => {
      reject(new Error(`${name} connection failed: ${error.message}`));
    });
  });
};

const joinConversation = (socket, name) => {
  return new Promise((resolve, reject) => {
    socket.emit(
      "join_conversation",
      { conversationId: CONVERSATION_ID },
      (response) => {
        if (!response || !response.success) {
          return reject(
            new Error(`${name} could not join: ${response?.message}`)
          );
        }

        console.log(`${name} joined the conversation.`);
        resolve();
      }
    );
  });
};

const waitForNewMessage = (socket) => {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      socket.off("new_message", handleMessage);
      reject(new Error("Jordan did not receive the message within 10 seconds."));
    }, 10000);

    const handleMessage = (payload) => {
      clearTimeout(timeout);
      resolve(payload);
    };

    socket.once("new_message", handleMessage);
  });
};

const sendMessage = (socket, text) => {
  return new Promise((resolve, reject) => {
    socket.emit(
      "send_message",
      {
        conversationId: CONVERSATION_ID,
        text
      },
      (response) => {
        if (!response || !response.success) {
          return reject(
            new Error(`Message sending failed: ${response?.message}`)
          );
        }

        console.log("Alex's message was saved successfully.");
        resolve(response.data);
      }
    );
  });
};

const main = async () => {
  let alexSocket;
  let jordanSocket;

  try {
    if (!ALEX_TOKEN || !JORDAN_TOKEN) {
      throw new Error(
        "Set both ALEX_TOKEN and JORDAN_TOKEN environment variables first."
      );
    }

    console.log("\nConnecting Alex and Jordan...\n");

    alexSocket = await connectSocket("Alex", ALEX_TOKEN);
    jordanSocket = await connectSocket("Jordan", JORDAN_TOKEN);

    console.log("\nJoining conversation...\n");

    await joinConversation(alexSocket, "Alex");
    await joinConversation(jordanSocket, "Jordan");

    // Start listening before Alex sends the message.
    const receivedMessagePromise = waitForNewMessage(jordanSocket);

    console.log("\nAlex is sending a message...\n");

    const savedMessage = await sendMessage(alexSocket, TEST_MESSAGE);

    console.log("Saved message ID:", savedMessage._id);

    // Wait for Jordan to receive the broadcast.
    const receivedPayload = await receivedMessagePromise;

    console.log("\nJordan received a real-time message!");
    console.log("Message:", receivedPayload.message.text);
    console.log("Sender:", receivedPayload.message.sender.name);
    console.log("Message ID:", receivedPayload.message._id);

    if (receivedPayload.message._id !== savedMessage._id) {
      throw new Error("Received message ID does not match saved message ID.");
    }

    console.log("\nSUCCESS: Real-time messaging works!");
  } catch (error) {
    console.error("\nTEST FAILED:", error.message);
    process.exitCode = 1;
  } finally {
    if (alexSocket) alexSocket.disconnect();
    if (jordanSocket) jordanSocket.disconnect();
  }
};

main();
