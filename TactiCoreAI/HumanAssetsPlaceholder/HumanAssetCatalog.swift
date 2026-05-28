import SwiftUI

enum HumanAssetKind: String, CaseIterable, Identifiable {
    case eliteCoach
    case trainingGround
    case footballerAction
    case tacticalDuel
    case playerSilhouette
    case stadiumTunnel
    case recoveryCircle
    case matchAnalysis

    var id: String { rawValue }

    var title: String {
        switch self {
        case .eliteCoach:
            return "Elite Coach Placeholder"
        case .trainingGround:
            return "Training Ground Photography Placeholder"
        case .footballerAction:
            return "Explosive Footballer Action Placeholder"
        case .tacticalDuel:
            return "Tactical Duel Scene Placeholder"
        case .playerSilhouette:
            return "Premium Player Silhouette Placeholder"
        case .stadiumTunnel:
            return "Stadium Tunnel Atmosphere Placeholder"
        case .recoveryCircle:
            return "Human Recovery Circle Placeholder"
        case .matchAnalysis:
            return "Analyst Reviewing Match Placeholder"
        }
    }

    var subtitle: String {
        switch self {
        case .eliteCoach:
            return "Coach profile, sideline emotion, leadership"
        case .trainingGround:
            return "Floodlit pitch, cones, players in motion"
        case .footballerAction:
            return "Sprint, press, first touch, contact"
        case .tacticalDuel:
            return "1v1 pressure moment with tactical overlay"
        case .playerSilhouette:
            return "Anonymous player identity for squads"
        case .stadiumTunnel:
            return "Pre-session cinematic focus"
        case .recoveryCircle:
            return "Team reflection and recovery"
        case .matchAnalysis:
            return "Video-room analysis and decision making"
        }
    }

    var accent: Color {
        switch self {
        case .eliteCoach:
            return .tactiCoreGold
        case .trainingGround:
            return .tactiCoreNeon
        case .footballerAction:
            return .tactiCoreBlue
        case .tacticalDuel:
            return .tactiCoreRed
        case .playerSilhouette:
            return .tactiCoreMint
        case .stadiumTunnel:
            return .tactiCorePurple
        case .recoveryCircle:
            return .tactiCoreTeal
        case .matchAnalysis:
            return .tactiCoreAmber
        }
    }
}

struct HumanAssetSlot: Identifiable, Hashable {
    let id = UUID()
    var kind: HumanAssetKind
    var usage: String
}

enum HumanAssetCatalog {
    static let hero = HumanAssetSlot(kind: .stadiumTunnel, usage: "Dashboard and onboarding hero")
    static let session = HumanAssetSlot(kind: .trainingGround, usage: "Generated training plans")
    static let voice = HumanAssetSlot(kind: .eliteCoach, usage: "Voice coaching notes")
    static let board = HumanAssetSlot(kind: .footballerAction, usage: "Tactical board")
    static let analysis = HumanAssetSlot(kind: .matchAnalysis, usage: "Match analysis")
    static let player = HumanAssetSlot(kind: .playerSilhouette, usage: "Player development")
}
