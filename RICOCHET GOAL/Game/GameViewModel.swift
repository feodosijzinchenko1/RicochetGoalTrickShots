import SwiftUI
import SpriteKit
import UIKit
import Combine

final class GameViewModel: ObservableObject {

    @Published var shots: Int = 0
    @Published var goals: Int = 0
    @Published var currentRicochet: Int = 0
    @Published var statusMessage: String = "Tap the pitch to pass"
    @Published var statusTint: Color = AppTheme.accent
    @Published var levelCompleted: Bool = false
    @Published var unlockedAchievement: AchievementInfo?

    let level: LevelConfig
    private let store = GameDataStore.shared
    private var builtScene: GameScene?

    init(levelID: Int) {
        self.level = GameCatalog.level(for: levelID)
        let stat = store.stat(for: levelID)
        self.goals = stat.goals
        self.shots = stat.shots
        self.levelCompleted = stat.completed
    }

    var targetGoals: Int { level.targetGoals }

    func scene(size: CGSize) -> GameScene {
        if let existing = builtScene {
            return existing
        }
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.configure(level: level, skin: GameCatalog.skin(for: store.selectedSkin))
        FeedbackManager.shared.prepare()
        bind(scene)
        builtScene = scene
        return scene
    }

    private func bind(_ scene: GameScene) {
        scene.onShoot = { [weak self] in
            guard let self else { return }
            self.store.recordShot(levelID: self.level.id)
            self.shots = self.store.stat(for: self.level.id).shots
            self.statusMessage = "Ball is live!"
            self.statusTint = AppTheme.accent
            FeedbackManager.shared.shoot()
        }
        scene.onRicochet = { [weak self] count in
            guard let self else { return }
            if count > self.currentRicochet {
                FeedbackManager.shared.ricochet()
            }
            self.currentRicochet = count
        }
        scene.onGoal = { [weak self] ricochets in
            guard let self else { return }
            let unlocked = self.store.recordGoal(levelID: self.level.id, ricochets: ricochets)
            let stat = self.store.stat(for: self.level.id)
            self.goals = stat.goals
            self.levelCompleted = stat.completed
            self.currentRicochet = ricochets
            self.statusMessage = ricochets >= 2 ? "GOAL! \(ricochets) ricochets" : "GOAL!"
            self.statusTint = AppTheme.accentSecondary
            FeedbackManager.shared.goal()
            if let first = unlocked.first {
                self.presentAchievement(first)
            }
        }
        scene.onMiss = { [weak self] in
            guard let self else { return }
            self.store.recordMiss(levelID: self.level.id)
            self.statusMessage = "Saved! Try a new angle"
            self.statusTint = Color(hex: "FF6B81")
            self.currentRicochet = 0
            FeedbackManager.shared.miss()
        }
    }

    private func presentAchievement(_ info: AchievementInfo) {
        withAnimation { unlockedAchievement = info }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { [weak self] in
            withAnimation { self?.unlockedAchievement = nil }
        }
    }

}
