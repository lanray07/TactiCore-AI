import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = OnboardingViewModel()
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .stadiumTunnel)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ScreenHeader(
                        eyebrow: "The modern operating system for elite football coaching",
                        title: "Train like a professional club.",
                        subtitle: "Create your coaching identity, define the tactical language, and let mock AI build your first training week.",
                        assetKind: .stadiumTunnel
                    )

                    selectionSection(title: "Coaching level") {
                        choiceGrid(CoachingLevel.allCases, selection: $viewModel.coachingLevel)
                    }

                    selectionSection(title: "Preferred tactical style") {
                        choiceGrid(TacticalStyle.allCases, selection: $viewModel.tacticalStyle)
                    }

                    selectionSection(title: "Age group coached") {
                        Picker("Age group", selection: $viewModel.ageGroup) {
                            ForEach(viewModel.ageGroups, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    selectionSection(title: "Formation preference") {
                        FlowLayout(viewModel.formations.map(IdentifiedString.init)) { item in
                            Button {
                                viewModel.formationPreference = item.value
                            } label: {
                                Chip(title: item.value, isSelected: viewModel.formationPreference == item.value, accent: .tactiCoreBlue)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    selectionSection(title: "Training frequency") {
                        Picker("Training frequency", selection: $viewModel.trainingFrequency) {
                            ForEach(viewModel.frequencies, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.tactiCoreNeon)
                    }

                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Training reminders")
                                .font(.headline.weight(.bold))
                            Text("Enable local reminders for upcoming sessions.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.62))
                        }
                    }
                    .tint(Color.tactiCoreNeon)
                    .padding(16)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                    if let error = viewModel.errorMessage {
                        ErrorStateView(message: error)
                    }

                    PremiumButton(title: "Generate Coaching Identity", systemImage: "sparkles", isLoading: viewModel.isGenerating) {
                        Task {
                            if viewModel.notificationsEnabled {
                                _ = await services.notificationService.requestAuthorization()
                            }
                            let completed = await viewModel.complete(modelContext: modelContext, aiService: services.aiService)
                            if completed { onFinished() }
                        }
                    }

                    Text(CoachingDisclaimer.short)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.bottom, 20)
                }
                .padding(20)
            }
        }
    }

    @ViewBuilder
    private func selectionSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                content()
            }
        }
    }

    private func choiceGrid<Value: Identifiable & RawRepresentable>(_ values: [Value], selection: Binding<Value>) -> some View where Value.RawValue == String {
        FlowLayout(values) { value in
            Button {
                selection.wrappedValue = value
            } label: {
                Chip(title: value.rawValue, isSelected: selection.wrappedValue.rawValue == value.rawValue)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct IdentifiedString: Identifiable {
    let id = UUID()
    let value: String
}
