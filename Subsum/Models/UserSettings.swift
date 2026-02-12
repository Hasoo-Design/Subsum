import Foundation
import SwiftData

@Model
final class UserSettings {
    var currency: String
    var defaultReminderDays: Int
    var isProUser: Bool
    var biometricLockEnabled: Bool
    var notificationsEnabled: Bool
    var hasCompletedOnboarding: Bool

    init(
        currency: String = "USD",
        defaultReminderDays: Int = 1,
        isProUser: Bool = false,
        biometricLockEnabled: Bool = false,
        notificationsEnabled: Bool = true,
        hasCompletedOnboarding: Bool = false
    ) {
        self.currency = currency
        self.defaultReminderDays = defaultReminderDays
        self.isProUser = isProUser
        self.biometricLockEnabled = biometricLockEnabled
        self.notificationsEnabled = notificationsEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
