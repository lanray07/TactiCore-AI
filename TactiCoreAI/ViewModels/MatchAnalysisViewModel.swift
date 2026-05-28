import Foundation

@MainActor
final class MatchAnalysisViewModel: ObservableObject {
    @Published var notes = "We pressed well for the first 20 minutes, but our midfield became stretched after losing the ball. Wide players were late to lock the touchline."
    @Published var formation = "4-3-3"
    @Published var tacticalStyle: TacticalStyle = .pressing
    @Published var result: MatchAnalysisResult?
    @Published var isAnalyzing = false
    @Published var errorMessage: String?

    let formations = ["4-3-3", "4-2-3-1", "3-5-2", "4-4-2", "3-4-3", "5-3-2"]

    func analyze(aiService: AIService) async {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }
        do {
            result = try await aiService.analyzeMatchNotes(notes, formation: formation, tacticalStyle: tacticalStyle.rawValue)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
