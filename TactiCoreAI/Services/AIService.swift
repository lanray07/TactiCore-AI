import Foundation

protocol AIService {
    func generateTrainingSession(input: TrainingSessionInput) async throws -> GeneratedTrainingSession
    func generateDrill(focus: String, ageGroup: String, formation: String) async throws -> GeneratedDrill
    func analyzeMatchNotes(_ notes: String, formation: String, tacticalStyle: String) async throws -> MatchAnalysisResult
    func summarizeVoiceInput(_ transcript: String) async throws -> String
    func generateCoachingInsights(profile: CoachProfile?, sessions: [TrainingSession]) async throws -> [CoachingInsight]
    func generatePlayerDevelopmentInsights(player: PlayerProfile) async throws -> [String]
}

enum AIServiceError: LocalizedError {
    case invalidEndpoint
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "The AI backend endpoint is not configured."
        case .emptyResponse:
            return "The AI backend returned an empty response."
        }
    }
}

struct MockAIService: AIService {
    func generateTrainingSession(input: TrainingSessionInput) async throws -> GeneratedTrainingSession {
        try await Task.sleep(nanoseconds: 550_000_000)

        let headline = "\(input.trainingFocus) Identity Session"
        let sections = [
            "Warm-Up: 10 minutes of rondo activation with scanning cues, open body shape, and two-touch tempo. Keep the ball alive while coaches cue pressing triggers from the outside.",
            "Activation: 8 minute directional possession wave. The team builds through the \(input.formation) shape, then reacts to a coach signal by counter-pressing for six seconds.",
            "Technical Drill: Split-unit passing pattern with bounce players, third-player runs, and disguised passes into the half-space. Rotate every two minutes to keep intensity high.",
            "Tactical Drill: Team shape rehearsal focused on \(input.tacticalGoal). The back line, midfield unit, and forwards move as one connected block with neon-zone constraints.",
            "Conditioned Game: \(input.playerCount)v\(max(input.playerCount - 1, 4)) game with bonus points for successful \(input.trainingFocus.lowercased()) actions and clean transition reactions.",
            "Reflection: Two-minute player-led debrief. Ask what the team saw, what triggered action, and how the next session can sharpen the tactical identity."
        ]

        let drills = [
            GeneratedDrill(
                title: "Neon Trigger Rondo",
                category: "Activation",
                instructions: "Players keep a compact diamond. On the coach cue, outside defenders step in and press while the possession group must escape through a mini gate.",
                coachingPoints: ["Scan before receiving", "Press on poor touch", "Protect the central lane"],
                animationPlaceholder: "Players circulate around a glowing central grid with a timed pressing arrow."
            ),
            GeneratedDrill(
                title: "Half-Space Breakout",
                category: "Tactical",
                instructions: "Build from the base of the \(input.formation). Progress into the half-space, set the ball back, then release the runner into the final zone.",
                coachingPoints: ["Create the third-player angle", "Keep distances short enough to counter-press", "Attack the next action at match tempo"],
                animationPlaceholder: "Animated midfield triangle, ball path, and forward run into the channel."
            ),
            GeneratedDrill(
                title: "Six-Second Recovery Game",
                category: "Conditioned Game",
                instructions: "When possession is lost, the nearest three players hunt the ball for six seconds. If they recover it, the team can finish into mini goals.",
                coachingPoints: ["React together", "Lock play outside", "Recover shape if the press is beaten"],
                animationPlaceholder: "Pressing trap zone lights up as player markers collapse around the ball."
            )
        ]

        return GeneratedTrainingSession(
            title: headline,
            tacticalFocus: input.trainingFocus,
            duration: input.duration,
            intensity: input.fitnessIntensity,
            formation: input.formation,
            playerCount: input.playerCount,
            sections: sections,
            drills: drills,
            coachingPoints: [
                "Use professional language but keep each cue short enough to land during play.",
                "Reward the behavior that matches the team identity, not only the outcome.",
                "Keep recovery windows honest so quality stays elite."
            ],
            transitionNotes: "Move from technical repetition into tactical realism by narrowing time and space every block.",
            recovery: "Finish with controlled breathing, hydration, and a short tactical reflection. No medical claims are made."
        )
    }

    func generateDrill(focus: String, ageGroup: String, formation: String) async throws -> GeneratedDrill {
        try await Task.sleep(nanoseconds: 250_000_000)
        return GeneratedDrill(
            title: "\(focus) Pattern Lab",
            category: "Animated Drill",
            instructions: "Use a realistic pitch channel, three player lines, and one ball. Build the repetition slowly before adding a defender and a transition target.",
            coachingPoints: ["Picture first", "Move on the pass", "Recover shape immediately"],
            animationPlaceholder: "Looping player movement, ball trail, and tactical zone overlay for \(formation)."
        )
    }

    func analyzeMatchNotes(_ notes: String, formation: String, tacticalStyle: String) async throws -> MatchAnalysisResult {
        try await Task.sleep(nanoseconds: 450_000_000)
        let hasTransitions = notes.localizedCaseInsensitiveContains("transition") || notes.localizedCaseInsensitiveContains("counter")
        return MatchAnalysisResult(
            tacticalWeaknesses: [
                "The midfield line opens too early when the first press is bypassed.",
                "Wide players are late to lock the touchline after negative passes.",
                hasTransitions ? "Rest defence needs clearer protection behind attacks." : "Transition data is light; add clip tags next match."
            ],
            trainingRecommendations: [
                "Run a compactness block in the \(formation) with live pressing triggers.",
                "Add a recovery game where the nearest three players counter-press before the team drops.",
                "Build next week around one clear \(tacticalStyle.lowercased()) behavior."
            ],
            pressingEfficiencyPlaceholder: "Pressing efficiency placeholder: 67 percent effective first-wave pressure.",
            shapeProblems: ["Back line and midfield distance stretched beyond 22 metres", "Weak-side winger detached from the block"],
            transitionIssues: ["First pass after regain lacks forward intent", "Counter-press becomes individual instead of collective"],
            nextSessionPriorities: ["Compact distances", "Touchline traps", "Rest defence"]
        )
    }

    func summarizeVoiceInput(_ transcript: String) async throws -> String {
        try await Task.sleep(nanoseconds: 350_000_000)
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "No voice content captured yet. Record a coaching idea, match observation, or session concept."
        }

        return """
        AI Coaching Summary:
        Convert this note into a focused session objective, then build two drills and one conditioned game around the clearest tactical behavior.

        Coach Intent:
        \(trimmed)

        Suggested Next Action:
        Create a 75-minute training plan with concise coaching cues, transition rules, and a player reflection prompt.
        """
    }

    func generateCoachingInsights(profile: CoachProfile?, sessions: [TrainingSession]) async throws -> [CoachingInsight] {
        try await Task.sleep(nanoseconds: 200_000_000)
        let style = profile?.tacticalStyle ?? "Balanced"
        let focus = sessions.first?.tacticalFocus ?? "Possession"
        return [
            CoachingInsight(title: "Identity Pulse", detail: "Your current plan is leaning toward \(style.lowercased()) football. Keep the language consistent across warm-up, drill, and match game.", tag: "Tactical"),
            CoachingInsight(title: "Next Session Edge", detail: "Build the first 20 minutes around \(focus.lowercased()) so players feel the session theme before the main practice.", tag: "Planning"),
            CoachingInsight(title: "Player Development Alert", detail: "Add one individual cue for each unit. Elite sessions feel personal even when the group is large.", tag: "Human")
        ]
    }

    func generatePlayerDevelopmentInsights(player: PlayerProfile) async throws -> [String] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return [
            "\(player.playerName) should receive one scanning cue before every possession practice.",
            "Design a two-week block that links \(player.position) responsibilities to tactical awareness.",
            "Use confidence language carefully: specific praise, clear next action, no guaranteed outcomes."
        ]
    }
}

struct RemoteAIService: AIService {
    private let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/tacticore-ai")
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func generateTrainingSession(input: TrainingSessionInput) async throws -> GeneratedTrainingSession {
        let request = try makeRequest(module: "trainingSession", input: input, voiceTranscript: "")
        let (data, _) = try await urlSession.data(for: request)
        let response = try JSONDecoder().decode(RemoteAIResponse.self, from: data)
        guard let session = response.trainingSession else { throw AIServiceError.emptyResponse }
        return session
    }

    func generateDrill(focus: String, ageGroup: String, formation: String) async throws -> GeneratedDrill {
        let input = TrainingSessionInput(ageGroup: ageGroup, duration: 60, playerCount: 14, formation: formation, tacticalGoal: focus, fitnessIntensity: FitnessIntensity.medium.rawValue, trainingFocus: focus, tacticalStyle: TacticalStyle.balanced.rawValue)
        let request = try makeRequest(module: "drill", input: input, voiceTranscript: "")
        let (data, _) = try await urlSession.data(for: request)
        let response = try JSONDecoder().decode(RemoteAIResponse.self, from: data)
        guard let drill = response.drills.first else { throw AIServiceError.emptyResponse }
        return drill
    }

    func analyzeMatchNotes(_ notes: String, formation: String, tacticalStyle: String) async throws -> MatchAnalysisResult {
        let input = TrainingSessionInput(ageGroup: "", duration: 0, playerCount: 0, formation: formation, tacticalGoal: "Match Analysis", fitnessIntensity: "", trainingFocus: "", tacticalStyle: tacticalStyle)
        let request = try makeRequest(module: "matchAnalysis", input: input, voiceTranscript: notes)
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(MatchAnalysisResult.self, from: data)
    }

    func summarizeVoiceInput(_ transcript: String) async throws -> String {
        let input = TrainingSessionInput(ageGroup: "", duration: 0, playerCount: 0, formation: "", tacticalGoal: "", fitnessIntensity: "", trainingFocus: "", tacticalStyle: "")
        let request = try makeRequest(module: "voiceSummary", input: input, voiceTranscript: transcript)
        let (data, _) = try await urlSession.data(for: request)
        let response = try JSONDecoder().decode(RemoteAIResponse.self, from: data)
        return response.summary
    }

    func generateCoachingInsights(profile: CoachProfile?, sessions: [TrainingSession]) async throws -> [CoachingInsight] {
        let mock = MockAIService()
        return try await mock.generateCoachingInsights(profile: profile, sessions: sessions)
    }

    func generatePlayerDevelopmentInsights(player: PlayerProfile) async throws -> [String] {
        let mock = MockAIService()
        return try await mock.generatePlayerDevelopmentInsights(player: player)
    }

    private func makeRequest(module: String, input: TrainingSessionInput, voiceTranscript: String) throws -> URLRequest {
        guard let endpoint = endpoint else { throw AIServiceError.invalidEndpoint }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = RemoteAIRequest(
            module: module,
            tacticalStyle: input.tacticalStyle,
            ageGroup: input.ageGroup,
            voiceTranscript: voiceTranscript,
            sessionFocus: input.trainingFocus.isEmpty ? input.tacticalGoal : input.trainingFocus,
            formation: input.formation
        )
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }
}

private struct RemoteAIRequest: Codable {
    var module: String
    var tacticalStyle: String
    var ageGroup: String
    var voiceTranscript: String
    var sessionFocus: String
    var formation: String
}

private struct RemoteAIResponse: Codable {
    var trainingSession: GeneratedTrainingSession?
    var drills: [GeneratedDrill]
    var coachingInsights: [String]
    var summary: String
}
