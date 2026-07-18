import Foundation

final class BridgeViewModel {

    private let destination: String
    private(set) var hasCompletedInitialLoad = false

    init(destination: String) {
        self.destination = destination
    }

    func makeRequest() -> URLRequest? {
        let trimmed = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let address = URL(string: trimmed) else { return nil }
        var request = URLRequest(url: address)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        return request
    }

    func markInitialLoadFinished() {
        hasCompletedInitialLoad = true
    }

    var shouldShowOverlay: Bool {
        return !hasCompletedInitialLoad
    }
}
