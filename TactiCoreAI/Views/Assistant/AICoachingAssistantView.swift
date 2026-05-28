import SwiftUI

struct AICoachingAssistantView: View {
    @StateObject private var viewModel = AssistantViewModel()

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .eliteCoach)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "AI Coaching Assistant",
                        title: "Professional language when the moment matters",
                        subtitle: "Generate coaching cues, halftime talks, motivation, reflections, and tactical reminders with realistic elite football tone.",
                        assetKind: .eliteCoach
                    )

                    PremiumContainer(accent: .tactiCoreNeon) {
                        VStack(alignment: .leading, spacing: 14) {
                            Picker("Assistant mode", selection: $viewModel.mode) {
                                ForEach(AssistantMode.allCases) { Text($0.rawValue).tag($0) }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.tactiCoreNeon)

                            TextEditor(text: $viewModel.prompt)
                                .frame(minHeight: 140)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }

                    PremiumButton(title: "Generate Coach Language", systemImage: "sparkles", isLoading: viewModel.isGenerating) {
                        Task { await viewModel.generate() }
                    }

                    if !viewModel.response.isEmpty {
                        TacticalInsightCard(
                            insight: CoachingInsight(title: viewModel.mode.rawValue, detail: viewModel.response, tag: "Coach AI"),
                            accent: .tactiCoreGold
                        )
                    }

                    Text(CoachingDisclaimer.short)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.56))
                }
                .padding(20)
            }
        }
        .navigationTitle("Assistant")
        .navigationBarTitleDisplayMode(.inline)
    }
}
