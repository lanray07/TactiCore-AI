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
            return "Touchline leadership"
        case .trainingGround:
            return "Floodlit training ground"
        case .footballerAction:
            return "Explosive player action"
        case .tacticalDuel:
            return "Pressing duel"
        case .playerSilhouette:
            return "Player development focus"
        case .stadiumTunnel:
            return "Elite matchday atmosphere"
        case .recoveryCircle:
            return "Team reflection"
        case .matchAnalysis:
            return "Analysis room"
        }
    }

    var subtitle: String {
        switch self {
        case .eliteCoach:
            return "Coach, assistant official, and tactical control"
        case .trainingGround:
            return "Players, staff, cones, tablets, and session detail"
        case .footballerAction:
            return "Sprint, press, first touch, and decision speed"
        case .tacticalDuel:
            return "1v1 pressure moment with tactical movement"
        case .playerSilhouette:
            return "Anonymous footballer imagery for squads"
        case .stadiumTunnel:
            return "Footballer and coach under stadium floodlights"
        case .recoveryCircle:
            return "Coach-led review, recovery, and planning"
        case .matchAnalysis:
            return "Analysts and officials reviewing match patterns"
        }
    }

    var imageName: String {
        switch self {
        case .eliteCoach:
            return "premium_training_officials"
        case .trainingGround:
            return "premium_training_officials"
        case .footballerAction:
            return "premium_tactical_duel"
        case .tacticalDuel:
            return "premium_tactical_duel"
        case .playerSilhouette:
            return "premium_tactical_duel"
        case .stadiumTunnel:
            return "premium_icon_scene"
        case .recoveryCircle:
            return "premium_training_officials"
        case .matchAnalysis:
            return "premium_analysis_room"
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
