
const User = require("../models/user");
const Swipe = require("../models/swipe");
const Connection = require("../models/connection");

// Calculate overlap between two arrays
const overlapScore = (arrayA = [], arrayB = []) => {
  if (!arrayA.length || !arrayB.length) return 0;

  const setA = new Set(arrayA.map(value => value.toLowerCase()));
  const setB = new Set(arrayB.map(value => value.toLowerCase()));

  const intersection = [...setA].filter(value => setB.has(value));

  return intersection.length / Math.max(setA.size, setB.size);
};

// Compare complementary skills in both directions
const skillScore = (userA, userB) => {
  const aToB = overlapScore(
    userA.skillsOffered,
    userB.skillsWanted
  );

  const bToA = overlapScore(
    userB.skillsOffered,
    userA.skillsWanted
  );

  return (aToB + bToA) / 2;
};

// Compare availability
const availabilityScore = (userA, userB) => {
  return overlapScore(
    userA.availability,
    userB.availability
  );
};

// Compare activity preferences
const wellnessScore = (userA, userB) => {
  if (
    !userA.activityPreference ||
    !userB.activityPreference
  ) {
    return 0.5;
  }

  if (
    userA.activityPreference ===
    userB.activityPreference
  ) {
    return 1;
  }

  const levels = ["low", "moderate", "high"];

  const difference = Math.abs(
    levels.indexOf(userA.activityPreference) -
    levels.indexOf(userB.activityPreference)
  );

  return difference === 1 ? 0.5 : 0;
};

// Compare general location
const locationScore = (userA, userB) => {
  const cityA = userA.location?.city?.trim().toLowerCase();
  const cityB = userB.location?.city?.trim().toLowerCase();

  if (!cityA || !cityB) return 0;

  return cityA === cityB ? 1 : 0;
};

// Calculate final compatibility score
const calculateCompatibility = (userA, userB) => {
  const interests = overlapScore(
    userA.interests,
    userB.interests
  );

  const skills = skillScore(userA, userB);

  const wellness = wellnessScore(userA, userB);

  const availability = availabilityScore(
    userA,
    userB
  );

  const location = locationScore(userA, userB);

  const score =
    interests * 25 +
    skills * 30 +
    wellness * 20 +
    availability * 15 +
    location * 10;

  return {
    score: Math.round(score),
    breakdown: {
      interests: Math.round(interests * 25),
      complementarySkills: Math.round(skills * 30),
      wellness: Math.round(wellness * 20),
      availability: Math.round(availability * 15),
      location: Math.round(location * 10)
    }
  };
};

// Retrieve ranked potential matches
const getRankedMatches = async (userId, page = 1, limit = 10) => {
  const currentUser = await User.findById(userId);

  if (!currentUser) {
    throw new Error("User not found.");
  }

  const oppositeRole =
    currentUser.role === "senior" ? "youth" : "senior";

  // Exclude users the current user has already swiped on
  const previousSwipes = await Swipe.find({
    fromUser: userId
  }).select("toUser");

  const excludedIds = previousSwipes.map(
    swipe => swipe.toUser
  );

  // Exclude existing connections
  const connections = await Connection.find({
    users: userId,
    status: "active"
  }).select("users");

  connections.forEach(connection => {
    connection.users.forEach(id => {
      if (id.toString() !== userId.toString()) {
        excludedIds.push(id);
      }
    });
  });

  const candidates = await User.find({
    _id: {
      $ne: userId,
      $nin: excludedIds
    },
    role: oppositeRole,
    profileCompleted: true
  });

  const ranked = candidates.map(candidate => {
    const compatibility = calculateCompatibility(
      currentUser,
      candidate
    );

    return {
      user: {
        id: candidate._id,
        name: candidate.name,
        age: candidate.age,
        role: candidate.role,
        interests: candidate.interests,
        skillsOffered: candidate.skillsOffered,
        skillsWanted: candidate.skillsWanted,
        goals: candidate.goals,
        activityPreference: candidate.activityPreference,
        meetingPreference: candidate.meetingPreference,
        availability: candidate.availability,
        location: candidate.location
      },
      compatibility
    };
  });

  ranked.sort(
    (a, b) =>
      b.compatibility.score - a.compatibility.score
  );

  const startIndex = (page - 1) * limit;

  return {
    total: ranked.length,
    page,
    limit,
    matches: ranked.slice(startIndex, startIndex + limit)
  };
};

module.exports = {
  calculateCompatibility,
  getRankedMatches
};
