import SwiftUI

enum AppRoute: Hashable {
    case levelSelect
    case game(Int)
    case statistics
    case howToPlay
    case achievements
    case settings
    case shop
}

struct MenuRootView: View {
    @StateObject private var store = GameDataStore.shared
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            MainMenuView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .environmentObject(store)
        .tint(AppTheme.accent)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .levelSelect:
            LevelSelectView(path: $path)
        case let .game(levelID):
            GameContainerView(levelID: levelID, path: $path)
        case .statistics:
            StatisticsView()
        case .howToPlay:
            HowToPlayView()
        case .achievements:
            AchievementsView()
        case .settings:
            SettingsView()
        case .shop:
            ShopView()
        }
    }
}
