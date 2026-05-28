import SwiftUI

struct ShareGraphicsView: View {
    @State private var selectedFormat = "Instagram"
    @State private var shareItems: [Any] = []
    @State private var isSharing = false
    private let formats = ["Instagram", "TikTok", "YouTube", "Story"]

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .footballerAction)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Shareable Coach Graphics",
                        title: "Make the training week look elite",
                        subtitle: "Premium social cards for session previews, tactical boards, coaching philosophy, and drill animation placeholders.",
                        assetKind: .footballerAction
                    )

                    PremiumContainer(accent: .tactiCoreGold) {
                        Picker("Format", selection: $selectedFormat) {
                            ForEach(formats, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    ShareCardPreview(
                        title: "\(selectedFormat) Training Week",
                        subtitle: "Pressing identity | 4-3-3 | Match tempo | Built with TactiCore AI",
                        accent: .tactiCoreNeon,
                        assetKind: .trainingGround
                    )

                    ShareCardPreview(
                        title: "Tactical Board Preview",
                        subtitle: "High press trigger: backward pass, loose touch, touchline lock",
                        accent: .tactiCoreBlue,
                        assetKind: .tacticalDuel
                    )

                    PremiumButton(title: "Share Placeholder Card", systemImage: "square.and.arrow.up.fill") {
                        shareItems = ["TactiCore AI \(selectedFormat) coaching graphic placeholder: Train like a professional club."]
                        isSharing = true
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Share")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSharing) {
            ShareSheet(items: shareItems)
        }
    }
}
