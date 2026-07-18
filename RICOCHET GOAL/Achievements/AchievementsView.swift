import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: GameDataStore

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 14) {
                    header
                    ForEach(GameCatalog.achievements) { achievement in
                        row(achievement, unlocked: store.isUnlocked(achievement.id))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var unlockedCount: Int {
        GameCatalog.achievements.filter { store.isUnlocked($0.id) }.count
    }

    private var header: some View {
        CardContainer {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "FFD56A"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlocked \(unlockedCount) of \(GameCatalog.achievements.count)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Keep banking goals to earn them all.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
            }
        }
    }

    private func row(_ info: AchievementInfo, unlocked: Bool) -> some View {
        CardContainer {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill((unlocked ? Color(hex: "FFD56A") : AppTheme.textSecondary).opacity(0.18))
                        .frame(width: 50, height: 50)
                    Image(systemName: unlocked ? info.icon : "lock.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(unlocked ? Color(hex: "FFD56A") : AppTheme.textSecondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(unlocked ? .white : AppTheme.textSecondary)
                    Text(info.details)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                if unlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.accentSecondary)
                }
            }
        }
    }
}
