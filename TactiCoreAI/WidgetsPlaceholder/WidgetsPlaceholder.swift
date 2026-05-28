import Foundation
import SwiftUI

struct TactiCoreWidgetTimelineEntry: Identifiable {
    let id = UUID()
    var date: Date
    var title: String
    var tacticalFocus: String
    var playerAlert: String
}

struct TactiCoreWidgetPlaceholderView: View {
    var entry = TactiCoreWidgetTimelineEntry(
        date: .now,
        title: "Next Session",
        tacticalFocus: "Pressing triggers",
        playerAlert: "CM scanning cue"
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TACTICORE AI")
                .font(.caption2.weight(.black))
                .foregroundStyle(Color.tactiCoreNeon)
            Text(entry.title)
                .font(.headline.weight(.black))
            Text(entry.tacticalFocus)
                .font(.caption.weight(.semibold))
            Text(entry.playerAlert)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.tactiCoreInk)
    }
}

enum TactiCoreWidgetArchitecturePlaceholder {
    static let supportedWidgets = ["Next session", "Tactical focus", "Player alert", "Coaching reminder"]
}
