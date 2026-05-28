import SwiftData
import SwiftUI

struct PlayerDevelopmentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @Query(sort: \PlayerProfile.createdAt, order: .reverse) private var players: [PlayerProfile]
    @StateObject private var viewModel = PlayerDevelopmentViewModel()

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .playerSilhouette)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Player Development Tracker",
                        title: "Make development feel personal",
                        subtitle: "Track technical, tactical, physical, and confidence placeholders with coach-reviewed AI development alerts.",
                        assetKind: .playerSilhouette
                    )

                    IconActionButton(title: "Add Demo Player", systemImage: "person.badge.plus.fill", accent: .tactiCoreNeon) {
                        viewModel.addPlayer(modelContext: modelContext)
                    }

                    if players.isEmpty {
                        EmptyStateView(title: "No player profiles", message: "Add a player to start tracking development metrics.", systemImage: "figure.soccer")
                    } else {
                        ForEach(players) { player in
                            playerCard(player)
                        }
                    }

                    if viewModel.isGenerating {
                        LoadingStateView(title: "Generating player development insight")
                    }

                    if !viewModel.generatedInsights.isEmpty {
                        PremiumContainer(accent: .tactiCoreGold) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("AI development plan for \(viewModel.selectedPlayerName)")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(.white)
                                ForEach(viewModel.generatedInsights, id: \.self) { insight in
                                    Label(insight, systemImage: "sparkles")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.76))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Players")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func playerCard(_ player: PlayerProfile) -> some View {
        PremiumContainer(accent: .tactiCoreMint) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    HumanAssetView(kind: .playerSilhouette, height: 104)
                        .frame(width: 108)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(player.playerName)
                            .font(.title3.weight(.black))
                            .foregroundStyle(.white)
                        Text(player.position)
                            .font(.caption.weight(.black))
                            .foregroundStyle(Color.tactiCoreNeon)
                        Text(player.latestInsight)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.66))
                            .lineLimit(3)
                    }
                    Spacer(minLength: 0)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    metric("Passing", player.passing, .tactiCoreNeon)
                    metric("Positioning", player.positioning, .tactiCoreBlue)
                    metric("Pace", player.pace, .tactiCoreGold)
                    metric("Strength", player.strength, .tactiCoreRed)
                    metric("Confidence", player.confidencePlaceholder, .tactiCorePurple)
                    metric("Discipline", player.discipline, .tactiCoreTeal)
                    metric("Tactical IQ", player.tacticalAwareness, .tactiCoreMint)
                    metric("Stamina", player.staminaPlaceholder, .tactiCoreAmber)
                }

                IconActionButton(title: "Generate Development Insights", systemImage: "sparkles", accent: .tactiCoreGold) {
                    Task { await viewModel.generateInsights(for: player, aiService: services.aiService) }
                }
            }
        }
    }

    private func metric(_ title: String, _ value: Int, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white.opacity(0.62))
                Spacer()
                Text("\(value)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(accent)
            }
            ProgressView(value: Double(value), total: 100)
                .tint(accent)
        }
        .padding(10)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
