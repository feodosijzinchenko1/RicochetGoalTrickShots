import SwiftUI

enum AppTheme {
    static let backgroundTop = Color(hex: "0A0E1F")
    static let backgroundBottom = Color(hex: "141B3C")
    static let accent = Color(hex: "5AD1FF")
    static let accentSecondary = Color(hex: "7CFFB0")
    static let card = Color(hex: "1C2547")
    static let cardBorder = Color(hex: "2E3A6B")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9AA6D4")
}

struct ScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = AppTheme.accent
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(tint.opacity(configuration.isPressed ? 0.65 : 1))
            )
            .foregroundColor(Color(hex: "0A0E1F"))
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct CardContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding(16)
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

struct StatChip: View {
    let title: String
    let value: String
    var tint: Color = AppTheme.accent
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(tint)
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.18))
        )
    }
}
