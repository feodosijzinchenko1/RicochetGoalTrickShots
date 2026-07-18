import SwiftUI
import SpriteKit

struct GameContainerView: View {
    let levelID: Int
    @Binding var path: NavigationPath
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init(levelID: Int, path: Binding<NavigationPath>) {
        self.levelID = levelID
        self._path = path
        self._viewModel = StateObject(wrappedValue: GameViewModel(levelID: levelID))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SpriteView(scene: viewModel.scene(size: geo.size), options: [.ignoresSiblingOrder])
                    .ignoresSafeArea()
                overlay
                if let achievement = viewModel.unlockedAchievement {
                    achievementToast(achievement)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var overlay: some View {
        VStack {
            topBar
            Spacer()
            statusBanner
            Spacer()
            bottomHint
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.black.opacity(0.35)))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(viewModel.level.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                HStack(spacing: 10) {
                    pill(icon: "soccerball", text: "\(viewModel.goals)/\(viewModel.targetGoals)")
                    pill(icon: "scope", text: "\(viewModel.shots) shots")
                    pill(icon: "arrow.triangle.2.circlepath", text: "\(viewModel.currentRicochet)")
                }
            }
        }
    }

    private func pill(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black.opacity(0.35)))
    }

    private var statusBanner: some View {
        Text(viewModel.statusMessage)
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundColor(viewModel.statusTint)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(Capsule().fill(Color.black.opacity(0.35)))
            .opacity(0.95)
    }

    private var bottomHint: some View {
        VStack(spacing: 6) {
            if viewModel.levelCompleted {
                Label("Level completed!", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accentSecondary)
            }
            Text("Drag to aim, release to pass. Bounce off the walls into the net.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.3)))
    }

    private func achievementToast(_ info: AchievementInfo) -> some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: info.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "FFD56A"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement unlocked")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Text(info.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.card))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "FFD56A"), lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.top, 70)
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
