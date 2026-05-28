import SwiftData
import SwiftUI

struct AnalyticsDashboardView: View {
    @Query(sort: \TrainingSession.createdAt, order: .reverse) private var sessions: [TrainingSession]
    @Query(sort: \PlayerProfile.createdAt, order: .reverse) private var players: [PlayerProfile]

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .trainingGround)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Analytics Dashboard",
                        title: "Read the coaching rhythm",
                        subtitle: "Training intensity, focus distribution, completion, player trends, consistency, and tactical identity placeholders.",
                        assetKind: .trainingGround
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        stat("Sessions", "\(sessions.count)", .tactiCoreNeon)
                        stat("Players", "\(players.count)", .tactiCoreBlue)
                        stat("Completion", "\(completionRate)%", .tactiCoreGold)
                        stat("Identity", topFocus, .tactiCorePurple)
                    }

                    AnalyticsChartCard(
                        title: "Tactical focus distribution",
                        subtitle: "Placeholder distribution from saved sessions",
                        data: focusData
                    )

                    AnalyticsChartCard(
                        title: "Player development trends",
                        subtitle: "Average placeholder player metrics",
                        data: playerData
                    )

                    TacticalInsightCard(
                        insight: CoachingInsight(title: "Tactical Identity Analysis Placeholder", detail: "Your current library is forming a clear \(topFocus.lowercased()) identity. Add defending and transition sessions to balance the training cycle.", tag: "Identity"),
                        accent: .tactiCoreNeon
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var completionRate: Int {
        guard !sessions.isEmpty else { return 0 }
        return Int(Double(sessions.filter(\.isCompleted).count) / Double(sessions.count) * 100)
    }

    private var topFocus: String {
        Dictionary(grouping: sessions, by: \.tacticalFocus)
            .max { $0.value.count < $1.value.count }?
            .key ?? "Balanced"
    }

    private var focusData: [AnalyticsChartCard.DataPoint] {
        let grouped = Dictionary(grouping: sessions, by: \.tacticalFocus)
        let fallback = [("Pressing", 5.0), ("Possession", 4.0), ("Transitions", 3.0), ("Finishing", 2.0)]
        let source = grouped.isEmpty ? fallback : grouped.map { ($0.key, Double($0.value.count)) }
        return source.prefix(6).enumerated().map { index, item in
            AnalyticsChartCard.DataPoint(label: item.0, value: item.1, color: [.tactiCoreNeon, .tactiCoreBlue, .tactiCoreGold, .tactiCorePurple, .tactiCoreTeal, .tactiCoreAmber][index % 6])
        }
    }

    private var playerData: [AnalyticsChartCard.DataPoint] {
        let averages = [
            ("Passing", average(\.passing)),
            ("Positioning", average(\.positioning)),
            ("Pace", average(\.pace)),
            ("Strength", average(\.strength)),
            ("Tactical", average(\.tacticalAwareness))
        ]
        return averages.enumerated().map { index, item in
            AnalyticsChartCard.DataPoint(label: item.0, value: item.1, color: [.tactiCoreNeon, .tactiCoreBlue, .tactiCoreGold, .tactiCoreRed, .tactiCorePurple][index])
        }
    }

    private func average(_ keyPath: KeyPath<PlayerProfile, Int>) -> Double {
        guard !players.isEmpty else { return 65 }
        return Double(players.map { $0[keyPath: keyPath] }.reduce(0, +)) / Double(players.count)
    }

    private func stat(_ title: String, _ value: String, _ accent: Color) -> some View {
        PremiumContainer(accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                Text(value)
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text(title.uppercased())
                    .font(.caption2.weight(.black))
                    .foregroundStyle(accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
