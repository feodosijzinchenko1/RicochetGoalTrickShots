import UIKit

enum DeviceInfo {

    static var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(Character(UnicodeScalar(UInt8(value))))
        }
        return identifier
    }

    static var systemDescription: String {
        return "\(UIDevice.current.systemName)\(UIDevice.current.systemVersion)"
    }

    static var primaryLanguage: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.components(separatedBy: "-").first ?? preferred
    }

    static var regionCode: String {
        if #available(iOS 16.0, *) {
            return Locale.current.region?.identifier ?? "US"
        }
        return Locale.current.regionCode ?? "US"
    }
}
