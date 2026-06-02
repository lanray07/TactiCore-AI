import Foundation
import StoreKit
import SwiftData
import SwiftUI
import UIKit
import UserNotifications

@MainActor
final class AppServices: ObservableObject {
    let aiService: AIService
    let remoteAIService: AIService
    let speechRecognitionService: SpeechRecognitionService
    let voiceRecordingService: VoiceRecordingService
    let voicePlaybackPlaceholder: VoicePlaybackPlaceholder
    let notificationService: NotificationService
    let pdfExportService: PDFExportService
    @Published var subscriptionStore: SubscriptionStore

    init(mockAIEnabled: Bool = true) {
        if mockAIEnabled {
            self.aiService = MockAIService()
        } else {
            self.aiService = RemoteAIService()
        }
        self.remoteAIService = RemoteAIService()
        self.speechRecognitionService = SpeechRecognitionService()
        self.voiceRecordingService = VoiceRecordingService()
        self.voicePlaybackPlaceholder = VoicePlaybackPlaceholder()
        self.notificationService = NotificationService()
        self.pdfExportService = PDFExportService()
        self.subscriptionStore = SubscriptionStore()
    }
}

@MainActor
final class SubscriptionStore: ObservableObject {
    static let productIDs = [
        "tacticore.pro.monthly",
        "tacticore.pro.yearly",
        "tacticore.elite.monthly"
    ]

    @Published var products: [Product] = []
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var isActive = false
    @Published var renewsAt: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let loadedProducts = try await Product.products(for: Self.productIDs)
            products = loadedProducts.sorted { lhs, rhs in
                (Self.productIDs.firstIndex(of: lhs.id) ?? .max) < (Self.productIDs.firstIndex(of: rhs.id) ?? .max)
            }
        } catch {
            products = []
            errorMessage = "Subscriptions are temporarily unavailable. Please try again in a moment."
        }
    }

    func product(for identifier: String) -> Product? {
        products.first { $0.id == identifier }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

#if os(visionOS)
        _ = product
#else
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    currentPlan = product.id.contains("elite") ? .eliteClub : .proCoach
                    isActive = true
                    renewsAt = transaction.expirationDate
                    await transaction.finish()
                case .unverified(_, _):
                    errorMessage = "Purchase could not be verified."
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase pending approval."
            @unknown default:
                errorMessage = "Unknown purchase state."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
#endif
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func activateMockPlan(_ plan: SubscriptionPlan) {
        currentPlan = plan
        isActive = plan != .free
        renewsAt = Calendar.current.date(byAdding: .month, value: 1, to: .now)
    }
}

final class NotificationService {
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleTrainingReminder(title: String, body: String, after seconds: TimeInterval = 12) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}

struct PDFExportService {
    @MainActor
    func renderSessionPDF(session: TrainingSession) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(session.title.replacingOccurrences(of: " ", with: "-")).pdf")

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            UIColor(red: 0.02, green: 0.05, blue: 0.04, alpha: 1).setFill()
            context.fill(pageRect)

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .black),
                .foregroundColor: UIColor.white
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor(white: 0.88, alpha: 1)
            ]
            let accentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: UIColor(red: 0.55, green: 1, blue: 0.34, alpha: 1)
            ]

            "TactiCore AI".draw(at: CGPoint(x: 42, y: 42), withAttributes: accentAttributes)
            session.title.draw(in: CGRect(x: 42, y: 72, width: 528, height: 72), withAttributes: titleAttributes)
            "\(session.tacticalFocus) | \(session.formation) | \(session.duration) minutes | \(session.intensity)".draw(in: CGRect(x: 42, y: 142, width: 528, height: 28), withAttributes: accentAttributes)
            session.generatedContent.draw(in: CGRect(x: 42, y: 190, width: 528, height: 430), withAttributes: bodyAttributes)
            "Coaching Points\n\(session.coachingPoints)\n\nDisclaimer: \(CoachingDisclaimer.short)".draw(in: CGRect(x: 42, y: 632, width: 528, height: 110), withAttributes: bodyAttributes)
        }

        return url
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension ModelContext {
    @MainActor
    func seedTactiCoreDemoDataIfNeeded() {
        let descriptor = FetchDescriptor<TrainingSession>()
        let existing = (try? fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let session = TrainingSession(
            title: "Pressing Identity Week",
            tacticalFocus: TrainingFocus.pressing.rawValue,
            duration: 75,
            intensity: FitnessIntensity.matchTempo.rawValue,
            formation: "4-3-3",
            playerCount: 18,
            generatedContent: "A cinematic, match-tempo session focused on first-wave pressure, compact midfield support, and six-second recovery after loss.",
            coachingPoints: "Press on poor touch. Protect the central lane. Recover shape if the first wave is beaten.",
            recoveryNotes: "Hydration, controlled breathing, short reflection."
        )
        insert(session)
        insert(Drill(sessionId: session.id, title: "Touchline Trap", category: "Tactical", instructions: "Lock the ball wide and press with three connected players.", coachingPoints: "Angle the run. Cover inside. Win the second ball.", animationPlaceholder: "Wide pressing arrows glow as the trap closes."))
        insert(PlayerProfile(playerName: "Alex Morgan", position: "CM", passing: 73, positioning: 71, pace: 68, strength: 65, confidencePlaceholder: 69, discipline: 77, tacticalAwareness: 72, staminaPlaceholder: 74))
        insert(PlayerProfile(playerName: "Rio Clarke", position: "LW", passing: 66, positioning: 64, pace: 82, strength: 61, confidencePlaceholder: 70, discipline: 67, tacticalAwareness: 63, staminaPlaceholder: 76))
        insert(TacticalBoard(title: "4-3-3 High Press", formation: "4-3-3", animationPlaceholder: "Front three screen centre-backs while eights jump to pivots."))
        insert(AnalyticsReport(reportType: "Tactical Identity", generatedInsights: "The current coaching identity trends toward high-intensity pressing with a need for more recovery detail."))
        insert(SubscriptionState())
        try? save()
    }
}
