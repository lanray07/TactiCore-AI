import Foundation
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var coachingLevel: CoachingLevel = .academy
    @Published var tacticalStyle: TacticalStyle = .pressing
    @Published var ageGroup = "U16"
    @Published var formationPreference = "4-3-3"
    @Published var trainingFrequency = "3 sessions / week"
    @Published var notificationsEnabled = true
    @Published var isGenerating = false
    @Published var errorMessage: String?

    let ageGroups = ["U8", "U10", "U12", "U14", "U16", "U18", "Senior"]
    let formations = ["4-3-3", "4-2-3-1", "3-5-2", "4-4-2", "3-4-3", "5-3-2"]
    let frequencies = ["1 session / week", "2 sessions / week", "3 sessions / week", "4 sessions / week", "Daily academy rhythm"]

    func complete(modelContext: ModelContext, aiService: AIService) async -> Bool {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let philosophy = "A \(tacticalStyle.rawValue.lowercased()) coaching identity for \(ageGroup), built around the \(formationPreference), clear cue language, player ownership, and high-quality session rhythm."
            let profile = CoachProfile(
                coachingLevel: coachingLevel.rawValue,
                tacticalStyle: tacticalStyle.rawValue,
                ageGroup: ageGroup,
                formationPreference: formationPreference,
                trainingFrequency: trainingFrequency,
                notificationsEnabled: notificationsEnabled,
                tacticalPhilosophySummary: philosophy
            )
            modelContext.insert(profile)

            let generated = try await aiService.generateTrainingSession(
                input: TrainingSessionInput(
                    ageGroup: ageGroup,
                    duration: 75,
                    playerCount: 18,
                    formation: formationPreference,
                    tacticalGoal: "Build the first AI-generated training week",
                    fitnessIntensity: FitnessIntensity.matchTempo.rawValue,
                    trainingFocus: tacticalStyle == .pressing ? TrainingFocus.pressing.rawValue : TrainingFocus.possession.rawValue,
                    tacticalStyle: tacticalStyle.rawValue
                )
            )

            let session = TrainingSession(
                title: "Week 1: \(generated.title)",
                tacticalFocus: generated.tacticalFocus,
                duration: generated.duration,
                intensity: generated.intensity,
                formation: generated.formation,
                playerCount: generated.playerCount,
                generatedContent: generated.generatedContent,
                coachingPoints: generated.coachingPoints.joined(separator: "\n"),
                recoveryNotes: generated.recovery
            )
            modelContext.insert(session)

            for drill in generated.drills {
                modelContext.insert(
                    Drill(
                        sessionId: session.id,
                        title: drill.title,
                        category: drill.category,
                        instructions: drill.instructions,
                        coachingPoints: drill.coachingPoints.joined(separator: "\n"),
                        animationPlaceholder: drill.animationPlaceholder
                    )
                )
            }

            try modelContext.save()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
