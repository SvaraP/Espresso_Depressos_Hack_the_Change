//
//  UserProfile.swift
//  Kindred
//
//  Created by svara on 11/7/26.
//

import Foundation
import Observation

// This is the format we'll eventually send to MongoDB.
struct UserProfile: Codable {

    var id: String = UUID().uuidString
    var name: String = ""
    var age: Int = 0
    var role: String = ""

    var participationRole: [String] = []
    var interests: [String] = []
    var skillsOffered: [String] = []
    var skillsWanted: [String] = []
    var goals: [String] = []

    var activityPreference: String = ""
    var meetingPreference: [String] = []
    var availability: [String] = []

    var location: UserLocation = UserLocation()
}

struct UserLocation: Codable {
    var city: String = ""
}

// This object holds the user's answers during signup.
@Observable
class SignupStore {
    var profile = UserProfile()
}
