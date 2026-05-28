import Foundation
import SwiftUI

struct BoardPlayer: Identifiable {
    let id = UUID()
    var number: Int
    var name: String
    var role: String
    var position: CGPoint
    var accent: Color = .tactiCoreNeon
}

struct TacticalMovement: Identifiable {
    let id = UUID()
    var start: CGPoint
    var end: CGPoint
    var label: String
    var accent: Color = .tactiCoreNeon
}

enum TacticalEnginePreset: String, CaseIterable, Identifiable {
    case highPress = "High Press"
    case transitionAttack = "Transition Attack"
    case defensiveShape = "Defensive Shape"
    case setPiece = "Set Piece"

    var id: String { rawValue }

    var movements: [TacticalMovement] {
        switch self {
        case .highPress:
            return [
                TacticalMovement(start: CGPoint(x: 0.28, y: 0.24), end: CGPoint(x: 0.39, y: 0.18), label: "Press"),
                TacticalMovement(start: CGPoint(x: 0.50, y: 0.31), end: CGPoint(x: 0.52, y: 0.19), label: "Jump"),
                TacticalMovement(start: CGPoint(x: 0.72, y: 0.24), end: CGPoint(x: 0.61, y: 0.18), label: "Lock")
            ]
        case .transitionAttack:
            return [
                TacticalMovement(start: CGPoint(x: 0.50, y: 0.65), end: CGPoint(x: 0.50, y: 0.39), label: "Break", accent: .tactiCoreBlue),
                TacticalMovement(start: CGPoint(x: 0.34, y: 0.55), end: CGPoint(x: 0.25, y: 0.31), label: "Run", accent: .tactiCoreBlue),
                TacticalMovement(start: CGPoint(x: 0.66, y: 0.55), end: CGPoint(x: 0.75, y: 0.31), label: "Run", accent: .tactiCoreBlue)
            ]
        case .defensiveShape:
            return [
                TacticalMovement(start: CGPoint(x: 0.24, y: 0.50), end: CGPoint(x: 0.33, y: 0.55), label: "Compact", accent: .tactiCoreGold),
                TacticalMovement(start: CGPoint(x: 0.76, y: 0.50), end: CGPoint(x: 0.67, y: 0.55), label: "Compact", accent: .tactiCoreGold)
            ]
        case .setPiece:
            return [
                TacticalMovement(start: CGPoint(x: 0.18, y: 0.18), end: CGPoint(x: 0.46, y: 0.16), label: "Delivery", accent: .tactiCoreAmber),
                TacticalMovement(start: CGPoint(x: 0.55, y: 0.27), end: CGPoint(x: 0.48, y: 0.12), label: "Attack", accent: .tactiCoreAmber)
            ]
        }
    }

    static func players(for formation: String) -> [BoardPlayer] {
        switch formation {
        case "3-5-2":
            return [
                BoardPlayer(number: 1, name: "GK", role: "GK", position: CGPoint(x: 0.50, y: 0.90), accent: .tactiCoreGold),
                BoardPlayer(number: 4, name: "LCB", role: "CB", position: CGPoint(x: 0.32, y: 0.75)),
                BoardPlayer(number: 5, name: "CB", role: "CB", position: CGPoint(x: 0.50, y: 0.76)),
                BoardPlayer(number: 6, name: "RCB", role: "CB", position: CGPoint(x: 0.68, y: 0.75)),
                BoardPlayer(number: 2, name: "LWB", role: "WB", position: CGPoint(x: 0.18, y: 0.56)),
                BoardPlayer(number: 8, name: "CM", role: "CM", position: CGPoint(x: 0.41, y: 0.56)),
                BoardPlayer(number: 10, name: "AM", role: "AM", position: CGPoint(x: 0.50, y: 0.45)),
                BoardPlayer(number: 7, name: "CM", role: "CM", position: CGPoint(x: 0.59, y: 0.56)),
                BoardPlayer(number: 3, name: "RWB", role: "WB", position: CGPoint(x: 0.82, y: 0.56)),
                BoardPlayer(number: 9, name: "ST", role: "ST", position: CGPoint(x: 0.43, y: 0.23)),
                BoardPlayer(number: 11, name: "ST", role: "ST", position: CGPoint(x: 0.57, y: 0.23))
            ]
        case "4-2-3-1":
            return [
                BoardPlayer(number: 1, name: "GK", role: "GK", position: CGPoint(x: 0.50, y: 0.90), accent: .tactiCoreGold),
                BoardPlayer(number: 2, name: "RB", role: "FB", position: CGPoint(x: 0.80, y: 0.74)),
                BoardPlayer(number: 4, name: "CB", role: "CB", position: CGPoint(x: 0.60, y: 0.78)),
                BoardPlayer(number: 5, name: "CB", role: "CB", position: CGPoint(x: 0.40, y: 0.78)),
                BoardPlayer(number: 3, name: "LB", role: "FB", position: CGPoint(x: 0.20, y: 0.74)),
                BoardPlayer(number: 6, name: "DM", role: "DM", position: CGPoint(x: 0.42, y: 0.61)),
                BoardPlayer(number: 8, name: "DM", role: "DM", position: CGPoint(x: 0.58, y: 0.61)),
                BoardPlayer(number: 7, name: "RW", role: "W", position: CGPoint(x: 0.76, y: 0.42)),
                BoardPlayer(number: 10, name: "AM", role: "AM", position: CGPoint(x: 0.50, y: 0.43)),
                BoardPlayer(number: 11, name: "LW", role: "W", position: CGPoint(x: 0.24, y: 0.42)),
                BoardPlayer(number: 9, name: "ST", role: "ST", position: CGPoint(x: 0.50, y: 0.22))
            ]
        default:
            return [
                BoardPlayer(number: 1, name: "GK", role: "GK", position: CGPoint(x: 0.50, y: 0.90), accent: .tactiCoreGold),
                BoardPlayer(number: 2, name: "RB", role: "FB", position: CGPoint(x: 0.82, y: 0.74)),
                BoardPlayer(number: 4, name: "CB", role: "CB", position: CGPoint(x: 0.60, y: 0.78)),
                BoardPlayer(number: 5, name: "CB", role: "CB", position: CGPoint(x: 0.40, y: 0.78)),
                BoardPlayer(number: 3, name: "LB", role: "FB", position: CGPoint(x: 0.18, y: 0.74)),
                BoardPlayer(number: 6, name: "DM", role: "DM", position: CGPoint(x: 0.50, y: 0.62)),
                BoardPlayer(number: 8, name: "RCM", role: "CM", position: CGPoint(x: 0.62, y: 0.49)),
                BoardPlayer(number: 10, name: "LCM", role: "CM", position: CGPoint(x: 0.38, y: 0.49)),
                BoardPlayer(number: 7, name: "RW", role: "W", position: CGPoint(x: 0.78, y: 0.28)),
                BoardPlayer(number: 11, name: "LW", role: "W", position: CGPoint(x: 0.22, y: 0.28)),
                BoardPlayer(number: 9, name: "ST", role: "ST", position: CGPoint(x: 0.50, y: 0.18))
            ]
        }
    }
}
