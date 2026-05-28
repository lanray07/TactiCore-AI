import Foundation

enum AssistantMode: String, CaseIterable, Identifiable {
    case coachingCues = "Coaching Cues"
    case halftimeTalk = "Halftime Talk"
    case motivation = "Player Motivation"
    case reflection = "Training Reflection"
    case tacticalReminder = "Tactical Reminder"

    var id: String { rawValue }
}

@MainActor
final class AssistantViewModel: ObservableObject {
    @Published var mode: AssistantMode = .coachingCues
    @Published var prompt = "We are struggling to maintain compactness after the first press is beaten."
    @Published var response = ""
    @Published var isGenerating = false

    func generate() async {
        isGenerating = true
        defer { isGenerating = false }
        try? await Task.sleep(nanoseconds: 300_000_000)
        switch mode {
        case .coachingCues:
            response = "Stay connected. Show outside. Protect the middle. If the press is broken, recover together before chasing the next duel."
        case .halftimeTalk:
            response = "We are in the game because our intensity is real. Now we need control. Shorter distances, clearer communication, and the next action after every regain."
        case .motivation:
            response = "Demand the detail from yourself, then help the player next to you. Elite teams make the simple action feel relentless."
        case .reflection:
            response = "The session should be reviewed through three questions: did players understand the trigger, did the unit move together, and did the game reward the identity?"
        case .tacticalReminder:
            response = "When the ball travels backwards, step. When the touch is loose, hunt. When the press is beaten, protect the space behind."
        }
        response += "\n\nInput context: \(prompt)"
    }
}
