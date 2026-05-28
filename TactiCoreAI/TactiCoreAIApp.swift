import SwiftData
import SwiftUI

@main
struct TactiCoreAIApp: App {
    @StateObject private var services = AppServices(mockAIEnabled: true)

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(services)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            CoachProfile.self,
            TrainingSession.self,
            Drill.self,
            PlayerProfile.self,
            VoiceTranscript.self,
            TacticalBoard.self,
            AnalyticsReport.self,
            SubscriptionState.self
        ])
    }
}
