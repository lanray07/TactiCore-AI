import SwiftData
import SwiftUI

struct SessionLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @Query(sort: \TrainingSession.createdAt, order: .reverse) private var sessions: [TrainingSession]
    @Query(sort: \Drill.createdAt, order: .reverse) private var drills: [Drill]
    @State private var searchText = ""
    @State private var shareItems: [Any] = []
    @State private var isSharePresented = false

    private var filteredSessions: [TrainingSession] {
        guard !searchText.isEmpty else { return sessions }
        return sessions.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.tacticalFocus.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .trainingGround)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Session Library",
                        title: "Your coaching vault",
                        subtitle: "Generated sessions, custom drills, tactical plans, weekly schedules, and academy pathway placeholders live locally.",
                        assetKind: .trainingGround
                    )

                    TextField("Search sessions, focuses, drills", text: $searchText)
                        .textFieldStyle(.plain)
                        .padding(14)
                        .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(.white.opacity(0.12)))

                    if filteredSessions.isEmpty {
                        EmptyStateView(title: "No saved sessions", message: "Generate a session and save it to build your premium library.", systemImage: "folder")
                    } else {
                        ForEach(filteredSessions) { session in
                            librarySessionCard(session)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom drills")
                            .font(.title3.weight(.black))
                            .foregroundStyle(.white)
                        ForEach(drills.prefix(5)) { drill in
                            DrillAnimationCard(title: drill.title, subtitle: drill.animationPlaceholder)
                        }
                    }

                    TacticalInsightCard(
                        insight: CoachingInsight(title: "Academy Pathways Placeholder", detail: "Future workspace for age-group curricula, club methodology, team collaboration, and progression ladders.", tag: "Elite Club"),
                        accent: .tactiCoreGold
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSharePresented) {
            ShareSheet(items: shareItems)
        }
    }

    private func librarySessionCard(_ session: TrainingSession) -> some View {
        VStack(spacing: 10) {
            SessionCard(session: session)
            HStack(spacing: 8) {
                IconActionButton(title: session.isFavorite ? "Favorited" : "Favorite", systemImage: session.isFavorite ? "star.fill" : "star", accent: .tactiCoreGold) {
                    session.isFavorite.toggle()
                    try? modelContext.save()
                }
                IconActionButton(title: "Duplicate", systemImage: "doc.on.doc.fill", accent: .tactiCoreBlue) {
                    duplicate(session)
                }
                IconActionButton(title: "Export", systemImage: "square.and.arrow.up.fill", accent: .tactiCoreNeon) {
                    export(session)
                }
            }
        }
    }

    private func duplicate(_ session: TrainingSession) {
        modelContext.insert(
            TrainingSession(
                title: "\(session.title) Copy",
                tacticalFocus: session.tacticalFocus,
                duration: session.duration,
                intensity: session.intensity,
                formation: session.formation,
                playerCount: session.playerCount,
                generatedContent: session.generatedContent,
                coachingPoints: session.coachingPoints,
                recoveryNotes: session.recoveryNotes,
                category: session.category
            )
        )
        try? modelContext.save()
    }

    private func export(_ session: TrainingSession) {
        do {
            let url = try services.pdfExportService.renderSessionPDF(session: session)
            shareItems = [url]
            isSharePresented = true
        } catch {
            shareItems = [session.generatedContent]
            isSharePresented = true
        }
    }
}
