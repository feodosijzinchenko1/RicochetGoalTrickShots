import SwiftUI

struct LevelSelectView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var store: GameDataStore

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(GameCatalog.levels) { level in
                        Button {
                            path.append(AppRoute.game(level.id))
                        } label: {
                            LevelCard(level: level, stat: store.stat(for: level.id))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Select Level")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct LevelCard: View {
    let level: LevelConfig
    let stat: LevelStat

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(level.subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                if stat.completed {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: level.palette.accent))
                }
            }
            HStack(spacing: 10) {
                badge(level.difficulty, system: "bolt.fill")
                badge("\(stat.goals)/\(level.targetGoals) goals", system: "soccerball")
                badge("\(stat.accuracyPercent)%", system: "scope")
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: level.palette.backgroundTop), Color(hex: level.palette.backgroundBottom)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: level.palette.border), lineWidth: 1.5)
                )
        )
    }

    private func badge(_ text: String, system: String) -> some View {
        Label(text, systemImage: system)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black.opacity(0.25)))
    }
}
