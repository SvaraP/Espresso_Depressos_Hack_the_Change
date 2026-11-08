
import Foundation
import Security

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}

struct RegistrationRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let age: Int
    let role: String
}

struct ProfileUpdateRequest: Encodable {
    let participationRoles: [String]
    let interests: [String]
    let skillsOffered: [String]
    let skillsWanted: [String]
    let goals: [String]
    let activityPreference: String
    let meetingPreference: String
    let availability: [String]
    let location: UserLocation
    let accessibilityNeeds: [String]
}

enum AuthError: LocalizedError {
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let message):
            return message
        }
    }
}

final class AuthService {

    static let shared = AuthService()

    private let baseURL = "http://127.0.0.1:5000/api/v1"

    private init() {}

    // MARK: - LOGIN

    func login(
        email: String,
        password: String
    ) async throws {

        let requestBody = LoginRequest(
            email: email,
            password: password
        )

        let data = try await sendRequest(
            endpoint: "/auth/login",
            method: "POST",
            body: requestBody
        )

        let response = try JSONDecoder().decode(
            LoginResponse.self,
            from: data
        )

        try saveToken(response.token)
    }

    // MARK: - REGISTER

    func register(
        name: String,
        email: String,
        password: String,
        age: Int,
        role: String,
        profile: UserProfile
    ) async throws {

        let requestBody = RegistrationRequest(
            name: name,
            email: email,
            password: password,
            age: age,
            role: role
        )

        let registrationData = try await sendRequest(
            endpoint: "/auth/register",
            method: "POST",
            body: requestBody
        )

        let registration = try JSONDecoder().decode(
            LoginResponse.self,
            from: registrationData
        )

        // Save token immediately after account creation.
        // If profile setup fails, the session can still be recovered.
        try saveToken(registration.token)

        // Convert meeting preferences to backend format
        let meetingPreference: String

        if profile.meetingPreference.contains("both") ||
            profile.meetingPreference.count > 1 {
            meetingPreference = "both"
        } else {
            meetingPreference =
                profile.meetingPreference.first ?? "both"
        }

        let profileBody = ProfileUpdateRequest(
            participationRoles: profile.participationRole,
            interests: profile.interests,
            skillsOffered: profile.skillsOffered,
            skillsWanted: profile.skillsWanted,
            goals: profile.goals,
            activityPreference: profile.activityPreference,
            meetingPreference: meetingPreference,
            availability: profile.availability,
            location: profile.location,
            accessibilityNeeds: []
        )

        _ = try await sendRequest(
            endpoint: "/users/me",
            method: "PUT",
            body: profileBody,
            token: registration.token
        )
    }

    // MARK: - HTTP REQUEST

    private func sendRequest<T: Encodable>(
        endpoint: String,
        method: String,
        body: T,
        token: String? = nil
    ) async throws -> Data {

        guard let url = URL(
            string: baseURL + endpoint
        ) else {
            throw AuthError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        if let token {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let http = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let message = String(
                data: data,
                encoding: .utf8
            ) ?? "Request failed."

            throw AuthError.serverError(message)
        }

        return data
    }

    // MARK: - KEYCHAIN

    private func saveToken(_ token: String) throws {

        let service = "Kindred"
        let account = "kindred.jwt"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)

        var attributes = query

        attributes[kSecValueData as String] =
            Data(token.utf8)

        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(
            attributes as CFDictionary,
            nil
        )

        guard status == errSecSuccess else {
            throw AuthError.serverError(
                "Unable to save authentication token."
            )
        }
    }
    
    
    func getSavedToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Kindred",
            kSecAttrAccount as String: "kindred.jwt",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

}
