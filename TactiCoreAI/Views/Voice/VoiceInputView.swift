import SwiftData
import SwiftUI

struct VoiceInputView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = VoiceInputViewModel()

    var body: some View {
        VoiceInputContent(
            speechService: services.speechRecognitionService,
            recordingService: services.voiceRecordingService,
            playbackPlaceholder: services.voicePlaybackPlaceholder,
            viewModel: viewModel,
            aiService: services.aiService,
            modelContext: modelContext
        )
    }
}

private struct VoiceInputContent: View {
    @ObservedObject var speechService: SpeechRecognitionService
    @ObservedObject var recordingService: VoiceRecordingService
    @ObservedObject var playbackPlaceholder: VoicePlaybackPlaceholder
    @ObservedObject var viewModel: VoiceInputViewModel
    let aiService: AIService
    let modelContext: ModelContext

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .eliteCoach)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Voice Input System",
                        title: "Speak the session into shape",
                        subtitle: "Dictate observations, match notes, tactical ideas, and AI will structure them into coach-ready summaries.",
                        assetKind: .eliteCoach
                    )

                    PremiumContainer(accent: speechService.isRecording ? .tactiCoreRed : .tactiCoreNeon) {
                        VStack(spacing: 14) {
                            VoiceWaveformView(levels: recordingService.levels, accent: speechService.isRecording ? .tactiCoreRed : .tactiCoreNeon)
                            HStack(spacing: 10) {
                                IconActionButton(title: speechService.isRecording ? "Pause" : "Record", systemImage: speechService.isRecording ? "pause.fill" : "mic.fill", accent: speechService.isRecording ? .tactiCoreRed : .tactiCoreNeon) {
                                    Task { await toggleRecording() }
                                }
                                IconActionButton(title: "Clear", systemImage: "xmark.circle.fill", accent: .white.opacity(0.65)) {
                                    speechService.stop(keepTranscript: false)
                                    recordingService.stopVisualizer()
                                    viewModel.editableTranscript = ""
                                }
                            }
                        }
                    }

                    if let error = speechService.errorMessage ?? viewModel.errorMessage {
                        ErrorStateView(message: error)
                    }

                    PremiumContainer(accent: .tactiCoreBlue) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Live transcription")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            TextEditor(text: $viewModel.editableTranscript)
                                .frame(minHeight: 160)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .foregroundStyle(.white)
                        }
                    }

                    PremiumButton(title: "Generate AI Coaching Summary", systemImage: "sparkles", isLoading: viewModel.isSummarizing) {
                        Task {
                            await viewModel.summarize(aiService: aiService, modelContext: modelContext)
                        }
                    }

                    if !viewModel.aiSummary.isEmpty {
                        TacticalInsightCard(
                            insight: CoachingInsight(title: "Voice to Coaching Plan", detail: viewModel.aiSummary, tag: "Voice"),
                            accent: .tactiCoreGold
                        )

                        IconActionButton(title: playbackPlaceholder.isPlaying ? "Playing Coach Voice" : "AI Voice Coaching Preview", systemImage: "speaker.wave.2.fill", accent: .tactiCoreGold) {
                            playbackPlaceholder.playAICoachPreview()
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Voice")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: speechService.transcript) { _, newValue in
            viewModel.syncTranscript(newValue)
        }
    }

    private func toggleRecording() async {
        if speechService.isRecording {
            speechService.pause()
            recordingService.stopVisualizer()
            return
        }

        if speechService.authorizationStatus == .notDetermined {
            await speechService.requestAuthorization()
        }

        do {
            try speechService.start()
            recordingService.startVisualizer()
        } catch {
            speechService.errorMessage = error.localizedDescription
            recordingService.stopVisualizer()
        }
    }
}
