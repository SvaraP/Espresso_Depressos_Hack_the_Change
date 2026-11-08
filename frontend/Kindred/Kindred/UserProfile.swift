
import Foundation
import Observation

// MARK: - USER PROFILE

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

    var activityPreference: String = "moderate"

    var meetingPreference: [String] = ["both"]

    var availability: [String] = []

    var location: UserLocation = UserLocation()

    // MARK: - ACCESSIBILITY REQUIREMENTS

    var accessibilityRequired: Bool? = nil

    var accessibilityNotes: String = ""
}

// MARK: - USER LOCATION

struct UserLocation: Codable {

    var city: String = ""
}

// MARK: - SIGNUP STORE

@Observable
class SignupStore {

    var profile = UserProfile()
}
