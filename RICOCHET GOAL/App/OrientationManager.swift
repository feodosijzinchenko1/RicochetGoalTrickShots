import UIKit

final class OrientationManager {
    static let shared = OrientationManager()

    private init() {}

    var mask: UIInterfaceOrientationMask = .portrait

    func lockPortrait() {
        mask = .portrait
        apply(.portrait)
    }

    func allowAll() {
        mask = [.portrait, .landscapeLeft, .landscapeRight]
        apply(mask)
    }

    private func apply(_ orientations: UIInterfaceOrientationMask) {
        guard let scene = activeWindowScene() else { return }
        let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientations)
        scene.requestGeometryUpdate(preferences) { _ in }
        scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }

    private func activeWindowScene() -> UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }
}

extension UIWindowScene {
    var keyWindow: UIWindow? {
        return windows.first(where: { $0.isKeyWindow }) ?? windows.first
    }
}
