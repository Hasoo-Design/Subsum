import SwiftUI
import SwiftData

@main
struct SubsumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Subscription.self, UserSettings.self])
    }
}
