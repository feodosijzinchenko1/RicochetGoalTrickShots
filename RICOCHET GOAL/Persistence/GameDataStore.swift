import Foundation
import Combine

final class GameDataStore: ObservableObject {
    static let shared = GameDataStore()

    private struct Snapshot: Codable {
        var levelStats: [Int: LevelStat]
        var coins: Int
        var ownedSkins: [String]
        var selectedSkin: String
        var unlockedAchievements: [String]
        var settings: SettingsState
    }

    @Published private(set) var levelStats: [Int: LevelStat]
    @Published private(set) var coins: Int
    @Published private(set) var ownedSkins: Set<String>
    @Published private(set) var selectedSkin: String
    @Published private(set) var unlockedAchievements: Set<String>
    @Published var settings: SettingsState {
        didSet { persist() }
    }

    private(set) var currentStreak: Int = 0
    private let storageKey = "ricochet_data_store_v1"

    private init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            levelStats = snapshot.levelStats
            coins = snapshot.coins
            ownedSkins = Set(snapshot.ownedSkins)
            selectedSkin = snapshot.selectedSkin
            unlockedAchievements = Set(snapshot.unlockedAchievements)
            settings = snapshot.settings
        } else {
            levelStats = [:]
            coins = 0
            ownedSkins = ["classic"]
            selectedSkin = "classic"
            unlockedAchievements = []
            settings = SettingsState()
        }
    }

    func stat(for levelID: Int) -> LevelStat {
        return levelStats[levelID] ?? LevelStat()
    }

    var totalGoals: Int {
        return levelStats.values.reduce(0) { $0 + $1.goals }
    }

    var totalShots: Int {
        return levelStats.values.reduce(0) { $0 + $1.shots }
    }

    var completedLevels: Int {
        return levelStats.values.filter { $0.completed }.count
    }

    var overallAccuracyPercent: Int {
        guard totalShots > 0 else { return 0 }
        return Int((Double(totalGoals) / Double(totalShots) * 100).rounded())
    }

    @discardableResult
    func recordShot(levelID: Int) -> Bool {
        var stat = stat(for: levelID)
        stat.shots += 1
        levelStats[levelID] = stat
        persist()
        return true
    }

    @discardableResult
    func recordGoal(levelID: Int, ricochets: Int) -> [AchievementInfo] {
        var stat = stat(for: levelID)
        stat.goals += 1
        stat.totalRicochets += ricochets
        stat.bestRicochetGoal = max(stat.bestRicochetGoal, ricochets)
        if stat.fastestGoalRicochets == 0 {
            stat.fastestGoalRicochets = ricochets
        } else {
            stat.fastestGoalRicochets = min(stat.fastestGoalRicochets, ricochets)
        }
        currentStreak += 1
        stat.bestStreak = max(stat.bestStreak, currentStreak)
        let target = GameCatalog.level(for: levelID).targetGoals
        if stat.goals >= target {
            stat.completed = true
        }
        levelStats[levelID] = stat

        coins += 10 + ricochets * 5

        let unlocked = evaluateAchievements(lastRicochets: ricochets)
        persist()
        return unlocked
    }

    func recordMiss(levelID: Int) {
        currentStreak = 0
        persist()
    }

    func resetStreak() {
        currentStreak = 0
    }

    func purchase(skin: ShopSkin) -> Bool {
        guard !ownedSkins.contains(skin.id) else { return true }
        guard coins >= skin.price else { return false }
        coins -= skin.price
        ownedSkins.insert(skin.id)
        _ = evaluateAchievements(lastRicochets: 0)
        persist()
        return true
    }

    func select(skin: ShopSkin) {
        guard ownedSkins.contains(skin.id) else { return }
        selectedSkin = skin.id
        persist()
    }

    func isUnlocked(_ achievementID: String) -> Bool {
        return unlockedAchievements.contains(achievementID)
    }

    func resetProgress() {
        levelStats = [:]
        coins = 0
        ownedSkins = ["classic"]
        selectedSkin = "classic"
        unlockedAchievements = []
        currentStreak = 0
        persist()
    }

    @discardableResult
    private func evaluateAchievements(lastRicochets: Int) -> [AchievementInfo] {
        var newlyUnlocked: [AchievementInfo] = []

        func unlock(_ id: String) {
            guard !unlockedAchievements.contains(id) else { return }
            unlockedAchievements.insert(id)
            if let info = GameCatalog.achievements.first(where: { $0.id == id }) {
                newlyUnlocked.append(info)
            }
        }

        if totalGoals >= 1 { unlock("first_goal") }
        if lastRicochets >= 2 { unlock("bank_shot") }
        if lastRicochets >= 3 { unlock("trick_shot") }
        if totalGoals >= 25 { unlock("sharp") }
        if currentStreak >= 5 { unlock("streak") }
        if completedLevels >= 1 { unlock("complete_one") }
        if completedLevels >= GameCatalog.levels.count { unlock("complete_all") }
        if ownedSkins.count >= 3 { unlock("collector") }

        return newlyUnlocked
    }

    private func persist() {
        let snapshot = Snapshot(
            levelStats: levelStats,
            coins: coins,
            ownedSkins: Array(ownedSkins),
            selectedSkin: selectedSkin,
            unlockedAchievements: Array(unlockedAchievements),
            settings: settings
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
