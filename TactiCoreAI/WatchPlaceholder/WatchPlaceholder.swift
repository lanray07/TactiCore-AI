import Foundation
import SwiftUI

struct WatchCoachingPrompt: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
}

struct TactiCoreWatchPlaceholderView: View {
    private let prompts = [
        WatchCoachingPrompt(title: "Reminder", detail: "Set the pressing trigger before block two."),
        WatchCoachingPrompt(title: "Stopwatch", detail: "Conditioned game: 4 x 4 minutes."),
        WatchCoachingPrompt(title: "Quick Note", detail: "Record a player cue after the session.")
    ]

    var body: some View {
        List(prompts) { prompt in
            VStack(alignment: .leading) {
                Text(prompt.title).font(.headline)
                Text(prompt.detail).font(.caption)
            }
        }
    }
}

enum TactiCoreWatchArchitecturePlaceholder {
    static let modules = ["Training reminders", "Stopwatch placeholder", "Coaching notes", "Quick tactical prompts"]
}
