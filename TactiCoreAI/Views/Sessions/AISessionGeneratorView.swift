import SwiftData
import SwiftUI

struct AISessionGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = SessionGeneratorViewModel()
    @State private var didSave = false

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .footballerAction)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "AI Session Generator",
                        title: "Build an elite training session",
                        subtitle: "Turn coaching intent into a professional warm-up, activation, technical block, tactical drill, conditioned game, and recovery plan.",
                        assetKind: .footballerAction
                    )

                    inputPanel

                    if let error = viewModel.errorMessage {
                        ErrorStateView(message: error)
                    }

                    PremiumButton(title: "Generate Session", systemImage: "sparkles", isLoading: viewModel.isGenerating) {
                        Task { await viewModel.generate(aiService: services.aiService) }
                    }

                    if let generated = viewModel.generatedSession {
                        generatedSessionView(generated)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Generate")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Saved to Session Library", isPresented: $didSave) {
            Button("OK", role: .cancel) {}
        }
    }

    private var inputPanel: some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 16) {
                picker("Age group", selection: $viewModel.ageGroup, values: viewModel.ageGroups)
                picker("Formation", selection: $viewModel.formation, values: viewModel.formations)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tactical goal")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.64))
                    TextField("Tactical goal", text: $viewModel.tacticalGoal, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(Int(viewModel.duration)) minutes")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.64))
                    Slider(value: $viewModel.duration, in: 45...120, step: 5)
                        .tint(Color.tactiCoreNeon)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Player count: \(Int(viewModel.playerCount))")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.64))
                    Slider(value: $viewModel.playerCount, in: 8...24, step: 1)
                        .tint(Color.tactiCoreBlue)
                }

                Picker("Intensity", selection: $viewModel.fitnessIntensity) {
                    ForEach(FitnessIntensity.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Training focus")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.64))
                    FlowLayout(TrainingFocus.allCases) { focus in
                        Button {
                            viewModel.trainingFocus = focus
                        } label: {
                            Chip(title: focus.rawValue, isSelected: viewModel.trainingFocus == focus, accent: .tactiCoreNeon)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func picker(_ title: String, selection: Binding<String>, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.64))
            Picker(title, selection: selection) {
                ForEach(values, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(Color.tactiCoreNeon)
        }
    }

    private func generatedSessionView(_ generated: GeneratedTrainingSession) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            PremiumCoachCard(
                title: generated.title,
                subtitle: "\(generated.tacticalFocus) | \(generated.formation) | \(generated.duration) minutes | \(generated.playerCount) players",
                metric: generated.intensity,
                assetKind: .trainingGround
            )

            ForEach(generated.sections, id: \.self) { section in
                PremiumContainer(accent: .tactiCoreNeon) {
                    Text(section)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(generated.drills) { drill in
                DrillAnimationCard(title: drill.title, subtitle: drill.animationPlaceholder)
            }

            PremiumButton(title: "Save to Library", systemImage: "tray.and.arrow.down.fill") {
                viewModel.saveGeneratedSession(modelContext: modelContext)
                didSave = true
            }
        }
    }
}
