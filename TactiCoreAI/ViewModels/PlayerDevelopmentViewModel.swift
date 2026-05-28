import Foundation
import SwiftData

@MainActor
final class PlayerDevelopmentViewModel: ObservableObject {
    @Published var selectedPlayerName = ""
    @Published var generatedInsights: [String] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?

    func addPlayer(modelContext: ModelContext) {
        let names = ["Maya Ellis", "Noah Reid", "Samir Khan", "Leo Foster", "Eva Brooks"]
        let positions = ["CB", "CM", "LW", "ST", "GK"]
        let index = Int.random(in: 0..<names.count)
        modelContext.insert(
            PlayerProfile(
                playerName: names[index],
                position: positions[index],
                passing: Int.random(in: 58...78),
                positioning: Int.random(in: 56...80),
                pace: Int.random(in: 60...84),
                strength: Int.random(in: 55...78),
                confidencePlaceholder: Int.random(in: 58...82),
                discipline: Int.random(in: 60...86),
                tacticalAwareness: Int.random(in: 55...80),
                staminaPlaceholder: Int.random(in: 58...84)
            )
        )
        try? modelContext.save()
    }

    func generateInsights(for player: PlayerProfile, aiService: AIService) async {
        selectedPlayerName = player.playerName
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }
        do {
            generatedInsights = try await aiService.generatePlayerDevelopmentInsights(player: player)
            player.latestInsight = generatedInsights.first ?? player.latestInsight
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
