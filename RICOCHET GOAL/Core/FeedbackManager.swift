import UIKit
import AudioToolbox

final class FeedbackManager {
    static let shared = FeedbackManager()

    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)

    private init() {}

    private var soundEnabled: Bool { GameDataStore.shared.settings.soundEnabled }
    private var hapticsEnabled: Bool { GameDataStore.shared.settings.hapticsEnabled }

    func prepare() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        lightImpactGenerator.prepare()
    }

    func shoot() {
        if soundEnabled { AudioServicesPlaySystemSound(1104) }
        if hapticsEnabled { impactGenerator.impactOccurred() }
    }

    func ricochet() {
        if soundEnabled { AudioServicesPlaySystemSound(1057) }
        if hapticsEnabled { lightImpactGenerator.impactOccurred(intensity: 0.7) }
    }

    func goal() {
        if soundEnabled { AudioServicesPlaySystemSound(1322) }
        if hapticsEnabled { notificationGenerator.notificationOccurred(.success) }
    }

    func miss() {
        if soundEnabled { AudioServicesPlaySystemSound(1323) }
        if hapticsEnabled { notificationGenerator.notificationOccurred(.warning) }
    }
}
