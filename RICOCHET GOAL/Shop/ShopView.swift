import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var store: GameDataStore
    @State private var notEnoughCoins = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 16) {
                    coinHeader
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(GameCatalog.skins) { skin in
                            SkinCard(
                                skin: skin,
                                owned: store.ownedSkins.contains(skin.id),
                                selected: store.selectedSkin == skin.id,
                                action: { handle(skin) }
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Not enough coins", isPresented: $notEnoughCoins) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Score more goals to earn coins, then come back.")
        }
    }

    private var coinHeader: some View {
        CardContainer {
            HStack {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(hex: "FFD56A"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.coins) coins")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Earn 10+ coins per goal, more for ricochets.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
            }
        }
    }

    private func handle(_ skin: ShopSkin) {
        if store.ownedSkins.contains(skin.id) {
            store.select(skin: skin)
        } else {
            let success = store.purchase(skin: skin)
            if success {
                store.select(skin: skin)
            } else {
                notEnoughCoins = true
            }
        }
    }
}

private struct SkinCard: View {
    let skin: ShopSkin
    let owned: Bool
    let selected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: skin.trailHex).opacity(0.25))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color(hex: skin.ballHex))
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(Color(hex: skin.trailHex), lineWidth: 2))
            }
            Text(skin.name)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text(buttonTitle)
            }
            .buttonStyle(PrimaryButtonStyle(tint: buttonTint))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(selected ? AppTheme.accentSecondary : AppTheme.cardBorder, lineWidth: selected ? 2 : 1)
                )
        )
    }

    private var buttonTitle: String {
        if selected { return "Selected" }
        if owned { return "Equip" }
        return skin.price == 0 ? "Free" : "\(skin.price)"
    }

    private var buttonTint: Color {
        if selected { return AppTheme.accentSecondary }
        if owned { return AppTheme.accent }
        return Color(hex: "FFD56A")
    }
}
