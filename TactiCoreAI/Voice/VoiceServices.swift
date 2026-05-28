import AVFoundation
import Foundation
import Speech
import SwiftUI

final class SpeechRecognitionService: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_GB"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        super.init()
        recognizer?.delegate = self
    }

    func requestAuthorization() async {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        await MainActor.run {
            authorizationStatus = status
        }
    }

    func start() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.stop()
                }
            }
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        DispatchQueue.main.async {
            self.isRecording = true
            self.errorMessage = nil
        }
    }

    func pause() {
        stop(keepTranscript: true)
    }

    func stop(keepTranscript: Bool = true) {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        DispatchQueue.main.async {
            self.isRecording = false
            if !keepTranscript {
                self.transcript = ""
            }
        }
    }

    func replaceTranscript(with value: String) {
        transcript = value
    }
}

@MainActor
final class VoiceRecordingService: ObservableObject {
    @Published var levels: [CGFloat] = Array(repeating: 0.22, count: 36)
    @Published var isVisualizing = false
    private var animationTask: Task<Void, Never>?

    func startVisualizer() {
        isVisualizing = true
        animationTask?.cancel()
        animationTask = Task { [weak self] in
            var phase: CGFloat = 0
            while !Task.isCancelled {
                phase += 0.11
                let generated = (0..<36).map { index in
                    StadiumWaveformAnimator.level(index: index, phase: phase)
                }
                await MainActor.run {
                    self?.levels = generated
                }
                try? await Task.sleep(nanoseconds: 70_000_000)
            }
        }
    }

    func stopVisualizer() {
        isVisualizing = false
        animationTask?.cancel()
        animationTask = nil
    }
}

enum StadiumWaveformAnimator {
    static func level(index: Int, phase: CGFloat) -> CGFloat {
        let base = sin(CGFloat(index) * 0.42 + phase) * 0.28
        let secondary = cos(CGFloat(index) * 0.19 + phase * 1.7) * 0.18
        return max(0.12, min(1, 0.48 + base + secondary))
    }
}

@MainActor
final class VoicePlaybackPlaceholder: ObservableObject {
    @Published var isPlaying = false

    func playAICoachPreview() {
        isPlaying = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                self.isPlaying = false
            }
        }
    }
}
