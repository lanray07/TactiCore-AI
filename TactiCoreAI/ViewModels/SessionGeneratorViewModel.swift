import Foundation
import SwiftData

@MainActor
final class SessionGeneratorViewModel: ObservableObject {
    @Published var ageGroup = "U16"
    @Published var duration = 75.0
    @Published var playerCount = 18.0
    @Published var formation = "4-3-3"
    @Published var tacticalGoal = "Win the ball high and attack quickly"
    @Published var fitnessIntensity: FitnessIntensity = .matchTempo
    @Published var trainingFocus: TrainingFocus = .pressing
    @Published var tacticalStyle: TacticalStyle = .pressing
    @Published var generatedSession: GeneratedTrainingSession?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    let ageGroups = ["U8", "U10", "U12", "U14", "U16", "U18", "Senior"]
    let formations = ["4-3-3", "4-2-3-1", "3-5-2", "4-4-2", "3-4-3", "5-3-2"]

    func generate(aiService: AIService) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }
        do {
            generatedSession = try await aiService.generateTrainingSession(
                input: TrainingSessionInput(
                    ageGroup: ageGroup,
                    duration: Int(duration),
                    playerCount: Int(playerCount),
                    formation: formation,
                    tacticalGoal: tacticalGoal,
                    fitnessIntensity: fitnessIntensity.rawValue,
                    trainingFocus: trainingFocus.rawValue,
                    tacticalStyle: tacticalStyle.rawValue
                )
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveGeneratedSession(modelContext: ModelContext) {
        guard let generatedSession else { return }
        let session = TrainingSession(
            title: generatedSession.title,
            tacticalFocus: generatedSession.tacticalFocus,
            duration: generatedSession.duration,
            intensity: generatedSession.intensity,
            formation: generatedSession.formation,
            playerCount: generatedSession.playerCount,
            generatedContent: generatedSession.generatedContent,
            coachingPoints: generatedSession.coachingPoints.joined(separator: "\n"),
            recoveryNotes: generatedSession.recovery
        )
        modelContext.insert(session)
        generatedSession.drills.forEach { generatedDrill in
            modelContext.insert(
                Drill(
                    sessionId: session.id,
                    title: generatedDrill.title,
                    category: generatedDrill.category,
                    instructions: generatedDrill.instructions,
                    coachingPoints: generatedDrill.coachingPoints.joined(separator: "\n"),
                    animationPlaceholder: generatedDrill.animationPlaceholder
                )
            )
        }
        try? modelContext.save()
    }
}
