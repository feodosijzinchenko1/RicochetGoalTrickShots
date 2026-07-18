import Foundation

final class TokenStorage {
    static let shared = TokenStorage()

    private let defaults = UserDefaults.standard
    private let tokenKey = "saved_access_token"
    private let destinationKey = "saved_destination_address"
    private let reviewKey = "did_request_review_flag"

    private init() {}

    var token: String? {
        get { defaults.string(forKey: tokenKey) }
        set { defaults.set(newValue, forKey: tokenKey) }
    }

    var destination: String? {
        get { defaults.string(forKey: destinationKey) }
        set { defaults.set(newValue, forKey: destinationKey) }
    }

    var hasSession: Bool {
        guard let token = token, !token.isEmpty,
              let destination = destination, !destination.isEmpty else { return false }
        return true
    }

    var didRequestReview: Bool {
        get { defaults.bool(forKey: reviewKey) }
        set { defaults.set(newValue, forKey: reviewKey) }
    }

    func store(token: String, destination: String) {
        self.token = token
        self.destination = destination
    }
}
