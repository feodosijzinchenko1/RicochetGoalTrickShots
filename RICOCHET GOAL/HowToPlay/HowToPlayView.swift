import SwiftUI

struct HowToPlayView: View {
    private struct Rule: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let text: String
    }

    private let rules: [Rule] = [
        Rule(icon: "hand.tap.fill", title: "One-touch passing", text: "Drag anywhere on the pitch to aim, then release. The ball travels toward that point."),
        Rule(icon: "arrow.triangle.2.circlepath", title: "Bank your shots", text: "You cannot shoot straight at the net. Bounce off the side walls and buffers to find an angle."),
        Rule(icon: "rectangle.split.2x1.fill", title: "Moving buffers", text: "Walls slide across the field. Time your pass so the ball ricochets exactly where you need it."),
        Rule(icon: "bolt.fill", title: "Boost pads", text: "Glowing rings accelerate the ball. Use them for fast, unpredictable angles."),
        Rule(icon: "figure.handball", title: "Fool the keeper", text: "The keeper jumps at the last moment toward the ball. A late ricochet changes the angle after he commits."),
        Rule(icon: "target", title: "Complete levels", text: "Score the required number of goals on each level to complete it and earn coins.")
    ]

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 16) {
                    diagram
                    ForEach(rules) { rule in
                        ruleRow(rule)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var diagram: some View {
        CardContainer {
            VStack(spacing: 10) {
                Text("The Idea")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("A hybrid of penalty football and billiards. Aim away from the goal, ricochet off the boards, and curl the ball into the net after one to three bounces.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    private func ruleRow(_ rule: Rule) -> some View {
        CardContainer {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.accent.opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: rule.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(rule.text)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
            }
        }
    }
}
