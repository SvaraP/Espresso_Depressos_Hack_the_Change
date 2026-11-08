
import Foundation
import Observation

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
}

struct UserLocation: Codable {
    var city: String = ""
}

@Observable
class SignupStore {
    var profile = UserProfile()
}
