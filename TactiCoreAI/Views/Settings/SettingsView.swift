import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @Query private var profiles: [CoachProfile]
    @Query private var sessions: [TrainingSession]
    @Query private var drills: [Drill]
    @Query private var players: [PlayerProfile]
    @Query private var transcripts: [VoiceTranscript]
    @Query private var boards: [TacticalBoard]
    @Query private var reports: [AnalyticsReport]
    @Query private var subscriptionStates: [SubscriptionState]
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var voiceEnabled = true
    @State private var notificationsEnabled = true
    @State private var cinematicTheme = true
    @State private var premiumPDF = true
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .stadiumTunnel)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Settings",
                        title: "Control the coaching OS",
                        subtitle: "Subscription, voice, tactical preferences, notifications, export settings, policies, and local data management.",
                        assetKind: .stadiumTunnel
                    )

                    settingsSection("Account") {
                        NavigationLink(value: AppRoute.paywall) {
                            row("Manage subscription", "crown.fill", .tactiCoreGold)
                        }
                        .buttonStyle(.plain)
                    }

                    settingsSection("Voice settings") {
                        Toggle("Voice input enabled", isOn: $voiceEnabled).tint(.tactiCoreNeon)
                        Toggle("AI voice coaching placeholder", isOn: .constant(true)).tint(.tactiCoreGold)
                    }

                    settingsSection("Tactical preferences") {
                        row("Default style: Pressing", "scope", .tactiCoreNeon)
                        row("Default formation: 4-3-3", "square.grid.3x3.fill", .tactiCoreBlue)
                    }

                    settingsSection("Notifications") {
                        Toggle("Training reminders", isOn: $notificationsEnabled)
                            .tint(.tactiCoreNeon)
                            .onChange(of: notificationsEnabled) { _, enabled in
                                if enabled {
                                    Task {
                                        _ = await services.notificationService.requestAuthorization()
                                        await services.notificationService.scheduleTrainingReminder(title: "TactiCore AI", body: "Your next coaching block is ready.")
                                    }
                                }
                            }
                    }

                    settingsSection("Theme and export") {
                        Toggle("Cinematic theme", isOn: $cinematicTheme).tint(.tactiCoreNeon)
                        Toggle("Premium PDF export styling", isOn: $premiumPDF).tint(.tactiCoreGold)
                    }

                    settingsSection("Legal and coaching") {
                        row("Privacy policy placeholder", "lock.shield.fill", .tactiCoreBlue)
                        row("Terms of use placeholder", "doc.text.fill", .tactiCoreBlue)
                        TacticalInsightCard(insight: CoachingInsight(title: "Coaching Disclaimer", detail: CoachingDisclaimer.full, tag: "Required"), accent: .tactiCoreGold)
                    }

                    PremiumContainer(accent: .tactiCoreRed) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Delete local data")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text("Removes profiles, sessions, drills, players, voice transcripts, boards, analytics reports, and subscription placeholder state from this device.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.62))
                            IconActionButton(title: "Delete All Data", systemImage: "trash.fill", accent: .tactiCoreRed) {
                                showDeleteConfirm = true
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete all local data?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) { deleteAllData() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(.tactiCoreNeon)
                content()
            }
        }
    }

    private func row(_ title: String, _ image: String, _ accent: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: image)
                .foregroundStyle(accent)
                .frame(width: 24)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func deleteAllData() {
        profiles.forEach { modelContext.delete($0) }
        sessions.forEach { modelContext.delete($0) }
        drills.forEach { modelContext.delete($0) }
        players.forEach { modelContext.delete($0) }
        transcripts.forEach { modelContext.delete($0) }
        boards.forEach { modelContext.delete($0) }
        reports.forEach { modelContext.delete($0) }
        subscriptionStates.forEach { modelContext.delete($0) }
        try? modelContext.save()
        hasCompletedOnboarding = false
    }
}
