import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    var isAuthorized = false

    private init() {}

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleNotification(for subscription: Subscription, reminderDays: Int) {
        let center = UNUserNotificationCenter.current()
        let identifier = subscription.id.uuidString

        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -reminderDays, to: subscription.nextChargeDate) else { return }

        guard triggerDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Charge"
        content.body = "\(subscription.name) — \(subscription.amount.formatted(currencyCode: subscription.currency)) renews in \(reminderDays) day\(reminderDays == 1 ? "" : "s")."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelNotification(for subscriptionID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [subscriptionID.uuidString])
    }

    func rescheduleAll(subscriptions: [Subscription], reminderDays: Int) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for sub in subscriptions where sub.isActive {
            scheduleNotification(for: sub, reminderDays: reminderDays)
        }
    }
}
