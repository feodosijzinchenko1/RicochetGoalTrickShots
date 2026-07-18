import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: GameDataStore

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 18) {
                    overallCard
                    ForEach(GameCatalog.levels) { level in
                        LevelStatsCard(level: level, stat: store.stat(for: level.id))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var overallCard: some View {
        CardContainer {
            VStack(spacing: 14) {
                Text("Career Overview")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 10) {
                    StatChip(title: "Goals", value: "\(store.totalGoals)")
                    StatChip(title: "Shots", value: "\(store.totalShots)")
                    StatChip(title: "Accuracy", value: "\(store.overallAccuracyPercent)%", tint: AppTheme.accentSecondary)
                }
                HStack(spacing: 10) {
                    StatChip(title: "Completed", value: "\(store.completedLevels)/\(GameCatalog.levels.count)", tint: Color(hex: "FFD56A"))
                    StatChip(title: "Coins", value: "\(store.coins)", tint: Color(hex: "FFD56A"))
                }
            }
        }
    }
}

private struct LevelStatsCard: View {
    let level: LevelConfig
    let stat: LevelStat

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Circle()
                        .fill(Color(hex: level.palette.accent))
                        .frame(width: 14, height: 14)
                    Text(level.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text(level.difficulty)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }

                ProgressView(value: Double(min(stat.goals, level.targetGoals)), total: Double(level.targetGoals))
                    .tint(Color(hex: level.palette.accent))

                HStack(spacing: 10) {
                    StatChip(title: "Goals", value: "\(stat.goals)")
                    StatChip(title: "Shots", value: "\(stat.shots)")
                    StatChip(title: "Accuracy", value: "\(stat.accuracyPercent)%", tint: AppTheme.accentSecondary)
                }
                HStack(spacing: 10) {
                    StatChip(title: "Best Ricochet", value: "\(stat.bestRicochetGoal)", tint: Color(hex: "FFD56A"))
                    StatChip(title: "Total Bounces", value: "\(stat.totalRicochets)")
                    StatChip(title: "Best Streak", value: "\(stat.bestStreak)", tint: Color(hex: "FF9F6B"))
                }

                HStack {
                    Image(systemName: stat.completed ? "checkmark.seal.fill" : "lock.open")
                        .foregroundColor(stat.completed ? AppTheme.accentSecondary : AppTheme.textSecondary)
                    Text(stat.completed ? "Completed" : "Target: \(level.targetGoals) goals")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}
