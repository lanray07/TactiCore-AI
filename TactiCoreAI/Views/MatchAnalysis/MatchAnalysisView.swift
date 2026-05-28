import SwiftUI

struct MatchAnalysisView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = MatchAnalysisViewModel()

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .matchAnalysis)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "AI Match Analysis",
                        title: "Turn match detail into training priorities",
                        subtitle: "Upload-style placeholders for notes, stats, clips, and voice analysis, with mock AI recommendations enabled.",
                        assetKind: .matchAnalysis
                    )

                    analysisInput

                    PremiumButton(title: "Analyze Match Notes", systemImage: "chart.line.uptrend.xyaxis", isLoading: viewModel.isAnalyzing) {
                        Task { await viewModel.analyze(aiService: services.aiService) }
                    }

                    if let error = viewModel.errorMessage {
                        ErrorStateView(message: error)
                    }

                    placeholders

                    if let result = viewModel.result {
                        analysisResult(result)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Match Analysis")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var analysisInput: some View {
        PremiumContainer(accent: .tactiCoreBlue) {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Formation", selection: $viewModel.formation) {
                    ForEach(viewModel.formations, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)

                Picker("Tactical style", selection: $viewModel.tacticalStyle) {
                    ForEach(TacticalStyle.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Color.tactiCoreNeon)

                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 170)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var placeholders: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            placeholder("Stats Placeholder", "number", .tactiCoreNeon)
            placeholder("Clips Placeholder", "play.rectangle.fill", .tactiCoreBlue)
            placeholder("Voice Analysis", "waveform", .tactiCoreGold)
            placeholder("Shape Map", "scope", .tactiCorePurple)
        }
    }

    private func placeholder(_ title: String, _ image: String, _ accent: Color) -> some View {
        PremiumContainer(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: image)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("Ready for backend media and stat ingestion.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.62))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func analysisResult(_ result: MatchAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TacticalInsightCard(insight: CoachingInsight(title: "Pressing Efficiency", detail: result.pressingEfficiencyPlaceholder, tag: "Placeholder"), accent: .tactiCoreGold)
            resultSection("Tactical weaknesses", values: result.tacticalWeaknesses, accent: .tactiCoreRed)
            resultSection("Training recommendations", values: result.trainingRecommendations, accent: .tactiCoreNeon)
            resultSection("Shape problems", values: result.shapeProblems, accent: .tactiCoreBlue)
            resultSection("Transition issues", values: result.transitionIssues, accent: .tactiCoreAmber)
            resultSection("Next-session priorities", values: result.nextSessionPriorities, accent: .tactiCorePurple)
        }
    }

    private func resultSection(_ title: String, values: [String], accent: Color) -> some View {
        PremiumContainer(accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                ForEach(values, id: \.self) { value in
                    Label(value, systemImage: "arrowtriangle.right.fill")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.76))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
