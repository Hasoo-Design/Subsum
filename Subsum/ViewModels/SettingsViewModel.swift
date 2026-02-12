import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    var modelContext: ModelContext?

    var settings: UserSettings?

    func fetchSettings() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? context.fetch(descriptor)) ?? []
        if let existing = results.first {
            settings = existing
        } else {
            let newSettings = UserSettings()
            context.insert(newSettings)
            try? context.save()
            settings = newSettings
        }
    }

    func save() {
        try? modelContext?.save()
    }

    var currency: String {
        get { settings?.currency ?? "USD" }
        set {
            settings?.currency = newValue
            save()
        }
    }

    var isProUser: Bool {
        get { settings?.isProUser ?? false }
        set {
            settings?.isProUser = newValue
            save()
        }
    }

    var hasCompletedOnboarding: Bool {
        get { settings?.hasCompletedOnboarding ?? false }
        set {
            settings?.hasCompletedOnboarding = newValue
            save()
        }
    }

    var defaultReminderDays: Int {
        get { settings?.defaultReminderDays ?? 1 }
        set {
            settings?.defaultReminderDays = newValue
            save()
        }
    }

    var biometricLockEnabled: Bool {
        get { settings?.biometricLockEnabled ?? false }
        set {
            settings?.biometricLockEnabled = newValue
            save()
        }
    }

    var notificationsEnabled: Bool {
        get { settings?.notificationsEnabled ?? true }
        set {
            settings?.notificationsEnabled = newValue
            save()
        }
    }
}
