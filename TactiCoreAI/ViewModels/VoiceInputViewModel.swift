import Foundation
import SwiftData

@MainActor
final class VoiceInputViewModel: ObservableObject {
    @Published var editableTranscript = ""
    @Published var aiSummary = ""
    @Published var isSummarizing = false
    @Published var errorMessage: String?

    func syncTranscript(_ transcript: String) {
        guard editableTranscript.isEmpty || transcript.count > editableTranscript.count else { return }
        editableTranscript = transcript
    }

    func summarize(aiService: AIService, modelContext: ModelContext) async {
        isSummarizing = true
        errorMessage = nil
        defer { isSummarizing = false }
        do {
            aiSummary = try await aiService.summarizeVoiceInput(editableTranscript)
            modelContext.insert(VoiceTranscript(transcript: editableTranscript, aiSummary: aiSummary))
            try? modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
