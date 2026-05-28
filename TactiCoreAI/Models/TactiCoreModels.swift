import Foundation
import SwiftData
import SwiftUI

enum CoachingLevel: String, CaseIterable, Identifiable, Codable {
    case grassroots = "Grassroots"
    case academy = "Academy"
    case semiPro = "Semi-Pro"
    case school = "School"
    case privateCoach = "Private Coach"

    var id: String { rawValue }
}

enum TacticalStyle: String, CaseIterable, Identifiable, Codable {
    case possession = "Possession"
    case pressing = "Pressing"
    case counterAttack = "Counter Attack"
    case directPlay = "Direct Play"
    case highIntensity = "High Intensity"
    case balanced = "Balanced"

    var id: String { rawValue }
}

enum TrainingFocus: String, CaseIterable, Identifiable, Codable {
    case pressing = "Pressing"
    case finishing = "Finishing"
    case possession = "Possession"
    case transitions = "Transitions"
    case defending = "Defending"
    case passing = "Passing"
    case counterAttack = "Counter Attack"
    case buildUpPlay = "Build-Up Play"
    case smallSidedGames = "Small-Sided Games"
    case fitness = "Fitness"
    case attackingMovement = "Attacking Movement"
    case defensiveShape = "Defensive Shape"

    var id: String { rawValue }
}

enum FitnessIntensity: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case matchTempo = "Match Tempo"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free = "Free"
    case proCoach = "Pro Coach"
    case eliteClub = "Elite Club"

    var id: String { rawValue }
}

@Model
final class CoachProfile {
    @Attribute(.unique) var id: UUID
    var coachingLevel: String
    var tacticalStyle: String
    var ageGroup: String
    var formationPreference: String
    var trainingFrequency: String
    var notificationsEnabled: Bool
    var tacticalPhilosophySummary: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        coachingLevel: String,
        tacticalStyle: String,
        ageGroup: String,
        formationPreference: String,
        trainingFrequency: String,
        notificationsEnabled: Bool,
        tacticalPhilosophySummary: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.coachingLevel = coachingLevel
        self.tacticalStyle = tacticalStyle
        self.ageGroup = ageGroup
        self.formationPreference = formationPreference
        self.trainingFrequency = trainingFrequency
        self.notificationsEnabled = notificationsEnabled
        self.tacticalPhilosophySummary = tacticalPhilosophySummary
        self.createdAt = createdAt
    }
}

@Model
final class TrainingSession {
    @Attribute(.unique) var id: UUID
    var title: String
    var tacticalFocus: String
    var duration: Int
    var intensity: String
    var formation: String
    var playerCount: Int
    var generatedContent: String
    var coachingPoints: String
    var recoveryNotes: String
    var isCompleted: Bool
    var isFavorite: Bool
    var category: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        tacticalFocus: String,
        duration: Int,
        intensity: String,
        formation: String,
        playerCount: Int,
        generatedContent: String,
        coachingPoints: String,
        recoveryNotes: String,
        isCompleted: Bool = false,
        isFavorite: Bool = false,
        category: String = "AI Generated",
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.tacticalFocus = tacticalFocus
        self.duration = duration
        self.intensity = intensity
        self.formation = formation
        self.playerCount = playerCount
        self.generatedContent = generatedContent
        self.coachingPoints = coachingPoints
        self.recoveryNotes = recoveryNotes
        self.isCompleted = isCompleted
        self.isFavorite = isFavorite
        self.category = category
        self.createdAt = createdAt
    }
}

@Model
final class Drill {
    @Attribute(.unique) var id: UUID
    var sessionId: UUID?
    var title: String
    var category: String
    var instructions: String
    var coachingPoints: String
    var animationPlaceholder: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        sessionId: UUID? = nil,
        title: String,
        category: String,
        instructions: String,
        coachingPoints: String,
        animationPlaceholder: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.sessionId = sessionId
        self.title = title
        self.category = category
        self.instructions = instructions
        self.coachingPoints = coachingPoints
        self.animationPlaceholder = animationPlaceholder
        self.createdAt = createdAt
    }
}

@Model
final class PlayerProfile {
    @Attribute(.unique) var id: UUID
    var playerName: String
    var position: String
    var passing: Int
    var positioning: Int
    var pace: Int
    var strength: Int
    var confidencePlaceholder: Int
    var discipline: Int
    var tacticalAwareness: Int
    var staminaPlaceholder: Int
    var developmentMetricsPlaceholder: String
    var latestInsight: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        playerName: String,
        position: String,
        passing: Int = 68,
        positioning: Int = 66,
        pace: Int = 70,
        strength: Int = 63,
        confidencePlaceholder: Int = 64,
        discipline: Int = 72,
        tacticalAwareness: Int = 65,
        staminaPlaceholder: Int = 69,
        developmentMetricsPlaceholder: String = "Local coaching metrics placeholder",
        latestInsight: String = "Needs a focused block on scanning, body shape, and decision speed.",
        createdAt: Date = .now
    ) {
        self.id = id
        self.playerName = playerName
        self.position = position
        self.passing = passing
        self.positioning = positioning
        self.pace = pace
        self.strength = strength
        self.confidencePlaceholder = confidencePlaceholder
        self.discipline = discipline
        self.tacticalAwareness = tacticalAwareness
        self.staminaPlaceholder = staminaPlaceholder
        self.developmentMetricsPlaceholder = developmentMetricsPlaceholder
        self.latestInsight = latestInsight
        self.createdAt = createdAt
    }
}

@Model
final class VoiceTranscript {
    @Attribute(.unique) var id: UUID
    var transcript: String
    var aiSummary: String
    var source: String
    var createdAt: Date

    init(id: UUID = UUID(), transcript: String, aiSummary: String, source: String = "Voice Coach Notes", createdAt: Date = .now) {
        self.id = id
        self.transcript = transcript
        self.aiSummary = aiSummary
        self.source = source
        self.createdAt = createdAt
    }
}

@Model
final class TacticalBoard {
    @Attribute(.unique) var id: UUID
    var title: String
    var formation: String
    var animationPlaceholder: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, formation: String, animationPlaceholder: String, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.formation = formation
        self.animationPlaceholder = animationPlaceholder
        self.createdAt = createdAt
    }
}

@Model
final class AnalyticsReport {
    @Attribute(.unique) var id: UUID
    var reportType: String
    var generatedInsights: String
    var createdAt: Date

    init(id: UUID = UUID(), reportType: String, generatedInsights: String, createdAt: Date = .now) {
        self.id = id
        self.reportType = reportType
        self.generatedInsights = generatedInsights
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool
    var renewsAt: Date?

    init(id: UUID = UUID(), plan: String = SubscriptionPlan.free.rawValue, isActive: Bool = false, renewsAt: Date? = nil) {
        self.id = id
        self.plan = plan
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}

struct TrainingSessionInput: Codable, Equatable {
    var ageGroup: String
    var duration: Int
    var playerCount: Int
    var formation: String
    var tacticalGoal: String
    var fitnessIntensity: String
    var trainingFocus: String
    var tacticalStyle: String
}

struct GeneratedDrill: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var category: String
    var instructions: String
    var coachingPoints: [String]
    var animationPlaceholder: String
}

struct GeneratedTrainingSession: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var tacticalFocus: String
    var duration: Int
    var intensity: String
    var formation: String
    var playerCount: Int
    var sections: [String]
    var drills: [GeneratedDrill]
    var coachingPoints: [String]
    var transitionNotes: String
    var recovery: String

    var generatedContent: String {
        sections.joined(separator: "\n\n")
    }
}

struct MatchAnalysisResult: Codable, Hashable {
    var tacticalWeaknesses: [String]
    var trainingRecommendations: [String]
    var pressingEfficiencyPlaceholder: String
    var shapeProblems: [String]
    var transitionIssues: [String]
    var nextSessionPriorities: [String]
}

struct CoachingInsight: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
    var tag: String
}

struct DevelopmentMetric: Identifiable {
    var id = UUID()
    var title: String
    var value: Int
    var accent: Color
}
