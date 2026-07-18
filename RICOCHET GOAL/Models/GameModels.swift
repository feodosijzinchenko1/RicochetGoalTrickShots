import SwiftUI

struct LevelPalette {
    let backgroundTop: String
    let backgroundBottom: String
    let field: String
    let border: String
    let accent: String
    let goal: String
}

struct LevelConfig: Identifiable {
    let id: Int
    let name: String
    let subtitle: String
    let difficulty: String
    let palette: LevelPalette
    let bufferCount: Int
    let bufferSpeed: Double
    let keeperReaction: Double
    let keeperRange: Double
    let targetGoals: Int
    let boosterCount: Int
}

struct LevelStat: Codable {
    var shots: Int = 0
    var goals: Int = 0
    var bestRicochetGoal: Int = 0
    var totalRicochets: Int = 0
    var bestStreak: Int = 0
    var completed: Bool = false
    var fastestGoalRicochets: Int = 0

    var accuracy: Double {
        guard shots > 0 else { return 0 }
        return Double(goals) / Double(shots)
    }

    var accuracyPercent: Int {
        return Int((accuracy * 100).rounded())
    }
}

struct ShopSkin: Identifiable {
    let id: String
    let name: String
    let price: Int
    let ballHex: String
    let trailHex: String
}

struct AchievementInfo: Identifiable {
    let id: String
    let title: String
    let details: String
    let icon: String
}

struct SettingsState: Codable {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
}

enum GameCatalog {

    static let levels: [LevelConfig] = [
        LevelConfig(
            id: 0,
            name: "Midnight Pitch",
            subtitle: "Learn the bank shot",
            difficulty: "Rookie",
            palette: LevelPalette(backgroundTop: "0B1026", backgroundBottom: "1B2A4A", field: "16305C", border: "4F7CC2", accent: "5AD1FF", goal: "F8FAFF"),
            bufferCount: 1,
            bufferSpeed: 70,
            keeperReaction: 0.30,
            keeperRange: 150,
            targetGoals: 3,
            boosterCount: 0
        ),
        LevelConfig(
            id: 1,
            name: "Emerald Arena",
            subtitle: "Watch the moving wall",
            difficulty: "Amateur",
            palette: LevelPalette(backgroundTop: "04140C", backgroundBottom: "0C3B22", field: "0E5331", border: "33B36B", accent: "7CFFB0", goal: "F4FFF8"),
            bufferCount: 2,
            bufferSpeed: 95,
            keeperReaction: 0.26,
            keeperRange: 170,
            targetGoals: 4,
            boosterCount: 1
        ),
        LevelConfig(
            id: 2,
            name: "Crimson Court",
            subtitle: "Use the boosters",
            difficulty: "Pro",
            palette: LevelPalette(backgroundTop: "1A0508", backgroundBottom: "4A1018", field: "611420", border: "D45366", accent: "FF6B81", goal: "FFF2F4"),
            bufferCount: 3,
            bufferSpeed: 120,
            keeperReaction: 0.22,
            keeperRange: 190,
            targetGoals: 5,
            boosterCount: 1
        ),
        LevelConfig(
            id: 3,
            name: "Violet Storm",
            subtitle: "Chaos in the box",
            difficulty: "Expert",
            palette: LevelPalette(backgroundTop: "120524", backgroundBottom: "2E0F52", field: "3D1670", border: "9B5CFF", accent: "C79CFF", goal: "F8F2FF"),
            bufferCount: 4,
            bufferSpeed: 145,
            keeperReaction: 0.18,
            keeperRange: 210,
            targetGoals: 6,
            boosterCount: 2
        ),
        LevelConfig(
            id: 4,
            name: "Solar Final",
            subtitle: "Beat the perfect keeper",
            difficulty: "Legend",
            palette: LevelPalette(backgroundTop: "201400", backgroundBottom: "4D3500", field: "6B4B00", border: "FFB02E", accent: "FFD56A", goal: "FFFBEF"),
            bufferCount: 5,
            bufferSpeed: 170,
            keeperReaction: 0.15,
            keeperRange: 230,
            targetGoals: 7,
            boosterCount: 2
        )
    ]

    static func level(for id: Int) -> LevelConfig {
        return levels.first(where: { $0.id == id }) ?? levels[0]
    }

    static let skins: [ShopSkin] = [
        ShopSkin(id: "classic", name: "Classic White", price: 0, ballHex: "FFFFFF", trailHex: "5AD1FF"),
        ShopSkin(id: "ember", name: "Ember", price: 120, ballHex: "FF7A3C", trailHex: "FFD56A"),
        ShopSkin(id: "neon", name: "Neon Lime", price: 200, ballHex: "B6FF3C", trailHex: "7CFFB0"),
        ShopSkin(id: "magma", name: "Magma", price: 320, ballHex: "FF3C6E", trailHex: "FF6B81"),
        ShopSkin(id: "aurora", name: "Aurora", price: 450, ballHex: "9B5CFF", trailHex: "C79CFF"),
        ShopSkin(id: "gold", name: "Golden Strike", price: 600, ballHex: "FFD23C", trailHex: "FFB02E")
    ]

    static func skin(for id: String) -> ShopSkin {
        return skins.first(where: { $0.id == id }) ?? skins[0]
    }

    static let achievements: [AchievementInfo] = [
        AchievementInfo(id: "first_goal", title: "First Strike", details: "Score your very first goal.", icon: "soccerball"),
        AchievementInfo(id: "bank_shot", title: "Bank Master", details: "Score after at least 2 ricochets.", icon: "arrow.triangle.2.circlepath"),
        AchievementInfo(id: "trick_shot", title: "Trick Artist", details: "Score after at least 3 ricochets.", icon: "sparkles"),
        AchievementInfo(id: "sharp", title: "Sharpshooter", details: "Score 25 goals in total.", icon: "target"),
        AchievementInfo(id: "streak", title: "On Fire", details: "Score 5 goals in a row.", icon: "flame.fill"),
        AchievementInfo(id: "complete_one", title: "Stadium Opener", details: "Complete any level.", icon: "checkmark.seal.fill"),
        AchievementInfo(id: "complete_all", title: "Grand Champion", details: "Complete every level.", icon: "trophy.fill"),
        AchievementInfo(id: "collector", title: "Style Icon", details: "Own 3 different ball skins.", icon: "paintpalette.fill")
    ]
}
