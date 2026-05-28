import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var insights: [CoachingInsight] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func refresh(profile: CoachProfile?, sessions: [TrainingSession], aiService: AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            insights = try await aiService.generateCoachingInsights(profile: profile, sessions: sessions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completionRate(for sessions: [TrainingSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let completed = sessions.filter(\.isCompleted).count
        return Int((Double(completed) / Double(sessions.count)) * 100)
    }
}
