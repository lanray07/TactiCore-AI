import SwiftUI

struct AnimatedDrillEngineView: View {
    @State private var preset: TacticalEnginePreset = .highPress

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .tacticalDuel)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Animated Drill Engine",
                        title: "Show the pattern before players feel it",
                        subtitle: "Moving players, ball trails, tactical zones, pressing traps, attacking patterns, and transition arrows.",
                        assetKind: .tacticalDuel
                    )

                    PremiumContainer(accent: .tactiCoreNeon) {
                        Picker("Animation preset", selection: $preset) {
                            ForEach(TacticalEnginePreset.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    DrillAnimationCard(
                        title: preset.rawValue,
                        subtitle: "Premium placeholder loop with realistic player movement language and glowing tactical overlays.",
                        movements: preset.movements
                    )

                    TacticalInsightCard(
                        insight: CoachingInsight(
                            title: "Engine Architecture Placeholder",
                            detail: "This layer is ready for frame timelines, ball ownership, zone constraints, drill serialization, coach annotations, and exportable animation states.",
                            tag: "Animation"
                        ),
                        accent: .tactiCoreBlue
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle("Drill Engine")
        .navigationBarTitleDisplayMode(.inline)
    }
}
