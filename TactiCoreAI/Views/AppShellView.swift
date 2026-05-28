import SwiftData
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case generate = "Generate"
    case board = "Board"
    case players = "Players"
    case library = "Library"
    case more = "More"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            return "sportscourt.fill"
        case .generate:
            return "sparkles"
        case .board:
            return "scope"
        case .players:
            return "figure.soccer"
        case .library:
            return "folder.fill"
        case .more:
            return "ellipsis.circle.fill"
        }
    }
}

enum AppRoute: Hashable {
    case voice
    case matchAnalysis
    case analytics
    case shareGraphics
    case assistant
    case paywall
    case settings
    case drillEngine
}

struct AppShellView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabShell(selectedTab: $selectedTab)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .task {
            modelContext.seedTactiCoreDemoDataIfNeeded()
        }
    }
}

struct MainTabShell: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tabContent(tab)
                        .navigationDestination(for: AppRoute.self) { route in
                            routeView(route)
                        }
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.systemImage)
                }
                .tag(tab)
            }
        }
        .tint(Color.tactiCoreNeon)
    }

    @ViewBuilder
    private func tabContent(_ tab: AppTab) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
        case .generate:
            AISessionGeneratorView()
        case .board:
            TacticalBoardScreen()
        case .players:
            PlayerDevelopmentView()
        case .library:
            SessionLibraryView()
        case .more:
            MoreHubView()
        }
    }

    @ViewBuilder
    private func routeView(_ route: AppRoute) -> some View {
        switch route {
        case .voice:
            VoiceInputView()
        case .matchAnalysis:
            MatchAnalysisView()
        case .analytics:
            AnalyticsDashboardView()
        case .shareGraphics:
            ShareGraphicsView()
        case .assistant:
            AICoachingAssistantView()
        case .paywall:
            PaywallView()
        case .settings:
            SettingsView()
        case .drillEngine:
            AnimatedDrillEngineView()
        }
    }
}

struct MoreHubView: View {
    private let routes: [(String, String, AppRoute, HumanAssetKind)] = [
        ("Voice Coach Notes", "waveform", .voice, .eliteCoach),
        ("AI Match Analysis", "video.badge.waveform", .matchAnalysis, .matchAnalysis),
        ("Analytics Dashboard", "chart.xyaxis.line", .analytics, .trainingGround),
        ("Shareable Graphics", "square.and.arrow.up", .shareGraphics, .footballerAction),
        ("AI Coaching Assistant", "sparkles", .assistant, .stadiumTunnel),
        ("Animated Drill Engine", "play.rectangle.fill", .drillEngine, .tacticalDuel),
        ("Subscription", "crown.fill", .paywall, .recoveryCircle),
        ("Settings", "gearshape.fill", .settings, .playerSilhouette)
    ]

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .stadiumTunnel)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Club OS",
                        title: "More coaching tools",
                        subtitle: "Voice, analysis, assistant, exports, and operating-system settings.",
                        assetKind: .stadiumTunnel
                    )

                    ForEach(routes, id: \.0) { title, image, route, asset in
                        NavigationLink(value: route) {
                            PremiumCoachCard(
                                title: title,
                                subtitle: "Open the premium \(title.lowercased()) workflow.",
                                metric: "TactiCore module",
                                assetKind: asset
                            )
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .trailing) {
                            Image(systemName: image)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(asset.accent)
                                .padding(.trailing, 28)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.inline)
    }
}
