import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var services: AppServices
    @Query(sort: \CoachProfile.createdAt, order: .reverse) private var profiles: [CoachProfile]
    @Query(sort: \TrainingSession.createdAt, order: .reverse) private var sessions: [TrainingSession]
    @Query private var subscriptionStates: [SubscriptionState]
    @StateObject private var viewModel = DashboardViewModel()

    private var profile: CoachProfile? { profiles.first }
    private var upcomingSessions: [TrainingSession] { Array(sessions.prefix(3)) }

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .trainingGround)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "TactiCore AI",
                        title: "Elite coaching command centre",
                        subtitle: profile?.tacticalPhilosophySummary ?? "Plan the week, sharpen the identity, and deliver sessions with professional clarity.",
                        assetKind: .trainingGround
                    )

                    metricsGrid

                    quickActions

                    if viewModel.isLoading {
                        LoadingStateView(title: "Reading your coaching week")
                    } else {
                        ForEach(viewModel.insights) { insight in
                            TacticalInsightCard(insight: insight, accent: insight.tag == "Human" ? .tactiCoreGold : .tactiCoreNeon)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming sessions")
                            .font(.title3.weight(.black))
                            .foregroundStyle(.white)
                        if upcomingSessions.isEmpty {
                            EmptyStateView(title: "No sessions yet", message: "Generate a training session to start building the week.", systemImage: "calendar.badge.plus")
                        } else {
                            ForEach(upcomingSessions) { session in
                                SessionCard(session: session)
                            }
                        }
                    }

                    subscriptionStatus
                }
                .padding(20)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.refresh(profile: profile, sessions: sessions, aiService: services.aiService)
        }
        .refreshable {
            await viewModel.refresh(profile: profile, sessions: sessions, aiService: services.aiService)
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(title: "Tactical focus", value: profile?.tacticalStyle ?? "Balanced", image: "scope", accent: .tactiCoreNeon)
            metricCard(title: "Completion", value: "\(viewModel.completionRate(for: sessions))%", image: "checkmark.seal.fill", accent: .tactiCoreGold)
            metricCard(title: "Training load", value: "Medium", image: "bolt.heart.fill", accent: .tactiCoreBlue)
            metricCard(title: "Player alerts", value: "2", image: "person.crop.circle.badge.exclamationmark", accent: .tactiCoreRed)
        }
    }

    private func metricCard(title: String, value: String, image: String, accent: Color) -> some View {
        PremiumContainer(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: image)
                    .foregroundStyle(accent)
                Text(value)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title.uppercased())
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white.opacity(0.56))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var quickActions: some View {
        PremiumContainer(accent: .tactiCoreBlue) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick actions")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    NavigationLink(value: AppRoute.voice) { quickActionLabel("Voice Notes", "waveform", .tactiCoreGold) }
                    NavigationLink(value: AppRoute.matchAnalysis) { quickActionLabel("Match Analysis", "video.badge.waveform", .tactiCoreBlue) }
                    NavigationLink(value: AppRoute.drillEngine) { quickActionLabel("Drill Engine", "play.rectangle.fill", .tactiCoreNeon) }
                    NavigationLink(value: AppRoute.assistant) { quickActionLabel("AI Assistant", "sparkles", .tactiCorePurple) }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func quickActionLabel(_ title: String, _ image: String, _ accent: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: image)
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .font(.caption.weight(.black))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(accent.opacity(0.17), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var subscriptionStatus: some View {
        let plan = subscriptionStates.first?.plan ?? services.subscriptionStore.currentPlan.rawValue
        return NavigationLink(value: AppRoute.paywall) {
            UpgradeBanner(title: "Subscription: \(plan)", subtitle: "Free includes limited sessions. Pro and Elite unlock the full coaching OS.")
        }
        .buttonStyle(.plain)
    }
}
