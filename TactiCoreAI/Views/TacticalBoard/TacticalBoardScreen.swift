import SwiftData
import SwiftUI

struct TacticalBoardScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TacticalBoard.createdAt, order: .reverse) private var boards: [TacticalBoard]
    @State private var formation = "4-3-3"
    @State private var preset: TacticalEnginePreset = .highPress
    @State private var players = TacticalEnginePreset.players(for: "4-3-3")
    @State private var showZones = true
    @State private var boardTitle = "4-3-3 High Press"

    private let formations = ["4-3-3", "4-2-3-1", "3-5-2"]

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .footballerAction)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Interactive Tactical Board",
                        title: "Move the team, animate the idea",
                        subtitle: "Drag player avatars, rehearse pressing triggers, build transition patterns, and save tactical boards locally.",
                        assetKind: .footballerAction
                    )

                    controls

                    TacticalBoardView(players: $players, movements: preset.movements, showZones: showZones)

                    HStack(spacing: 10) {
                        IconActionButton(title: "Reset Shape", systemImage: "arrow.counterclockwise", accent: .tactiCoreBlue) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                players = TacticalEnginePreset.players(for: formation)
                            }
                        }
                        IconActionButton(title: "Save Board", systemImage: "tray.and.arrow.down.fill", accent: .tactiCoreNeon) {
                            saveBoard()
                        }
                    }

                    if boards.isEmpty {
                        EmptyStateView(title: "No saved boards", message: "Save a tactical idea to build your local board library.", systemImage: "scope")
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved tactical boards")
                                .font(.title3.weight(.black))
                                .foregroundStyle(.white)
                            ForEach(boards.prefix(4)) { board in
                                TacticalInsightCard(
                                    insight: CoachingInsight(title: board.title, detail: board.animationPlaceholder, tag: board.formation),
                                    accent: .tactiCoreBlue
                                )
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Tactical Board")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: formation) { _, newValue in
            players = TacticalEnginePreset.players(for: newValue)
            boardTitle = "\(newValue) \(preset.rawValue)"
        }
        .onChange(of: preset) { _, newValue in
            boardTitle = "\(formation) \(newValue.rawValue)"
        }
    }

    private var controls: some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 14) {
                TextField("Board title", text: $boardTitle)
                    .textFieldStyle(.plain)
                    .font(.headline.weight(.bold))
                    .padding(12)
                    .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Picker("Formation", selection: $formation) {
                    ForEach(formations, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)

                Picker("Pattern", selection: $preset) {
                    ForEach(TacticalEnginePreset.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Color.tactiCoreNeon)

                Toggle("Show tactical zones", isOn: $showZones)
                    .tint(Color.tactiCoreNeon)
            }
        }
    }

    private func saveBoard() {
        modelContext.insert(
            TacticalBoard(
                title: boardTitle,
                formation: formation,
                animationPlaceholder: "\(preset.rawValue): \(preset.movements.map(\.label).joined(separator: ", "))"
            )
        )
        try? modelContext.save()
    }
}
