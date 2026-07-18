import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameDataStore
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(spacing: 16) {
                    CardContainer {
                        VStack(spacing: 4) {
                            toggleRow(title: "Sound Effects", icon: "speaker.wave.2.fill", isOn: Binding(
                                get: { store.settings.soundEnabled },
                                set: { store.settings.soundEnabled = $0 }
                            ))
                            Divider().background(AppTheme.cardBorder)
                            toggleRow(title: "Haptics", icon: "iphone.radiowaves.left.and.right", isOn: Binding(
                                get: { store.settings.hapticsEnabled },
                                set: { store.settings.hapticsEnabled = $0 }
                            ))
                        }
                    }

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Progress")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Button(role: .destructive) {
                                showResetConfirm = true
                            } label: {
                                Label("Reset all progress", systemImage: "trash.fill")
                            }
                            .buttonStyle(PrimaryButtonStyle(tint: Color(hex: "FF6B81")))
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .confirmationDialog("Reset all progress?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { store.resetProgress() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears every level statistic, coin and unlocked skin.")
        }
    }

    private func toggleRow(title: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.accent)
                .frame(width: 30)
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(.vertical, 8)
    }
}
