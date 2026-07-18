import SwiftUI
import Combine

final class MainMenuViewModel: ObservableObject {
    struct MenuItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let route: AppRoute
        let tint: Color
    }

    let items: [MenuItem] = [
        MenuItem(title: "Play", subtitle: "Bend the ball into the net", icon: "play.fill", route: .levelSelect, tint: AppTheme.accent),
        MenuItem(title: "Statistics", subtitle: "Track every level", icon: "chart.bar.fill", route: .statistics, tint: AppTheme.accentSecondary),
        MenuItem(title: "How to Play", subtitle: "Rules and tips", icon: "questionmark.circle.fill", route: .howToPlay, tint: Color(hex: "FFD56A")),
        MenuItem(title: "Achievements", subtitle: "Unlock rewards", icon: "trophy.fill", route: .achievements, tint: Color(hex: "FF9F6B")),
        MenuItem(title: "Settings", subtitle: "Sound and progress", icon: "gearshape.fill", route: .settings, tint: Color(hex: "9AA6D4")),
        MenuItem(title: "Shop", subtitle: "New ball skins", icon: "bag.fill", route: .shop, tint: Color(hex: "C79CFF"))
    ]
}

struct MainMenuView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var store: GameDataStore
    @StateObject private var viewModel = MainMenuViewModel()

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 22) {
                    header
                    coinBar
                    VStack(spacing: 12) {
                        ForEach(viewModel.items) { item in
                            Button {
                                path.append(item.route)
                            } label: {
                                MenuRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("RICOCHET")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [AppTheme.accent, AppTheme.accentSecondary], startPoint: .leading, endPoint: .trailing)
                )
            Text("GOAL")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .tracking(14)
                .foregroundColor(AppTheme.textSecondary)
            Text("Bank it. Bounce it. Beat the keeper.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.top, 36)
    }

    private var coinBar: some View {
        HStack {
            Image(systemName: "circle.hexagongrid.fill")
                .foregroundColor(Color(hex: "FFD56A"))
            Text("\(store.coins)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
            Text("coins")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Label("\(store.completedLevels)/\(GameCatalog.levels.count)", systemImage: "flag.checkered")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.card)
        )
    }
}

private struct MenuRow: View {
    let item: MainMenuViewModel.MenuItem
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(item.tint.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: item.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(item.tint)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text(item.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}
