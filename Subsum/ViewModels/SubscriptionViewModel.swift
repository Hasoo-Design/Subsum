import Foundation
import SwiftData
import SwiftUI

@Observable
final class SubscriptionViewModel {
    var modelContext: ModelContext?

    var subscriptions: [Subscription] = []

    var activeSubscriptions: [Subscription] {
        subscriptions.filter(\.isActive)
    }

    var monthlyTotal: Decimal {
        activeSubscriptions.reduce(Decimal.zero) { $0 + $1.monthlyAmount }
    }

    var yearlyProjection: Decimal {
        monthlyTotal * 12
    }

    var upcomingCharges: [Subscription] {
        activeSubscriptions
            .filter { $0.nextChargeDate >= Calendar.current.startOfDay(for: .now) }
            .sorted { $0.nextChargeDate < $1.nextChargeDate }
    }

    var mostExpensive: Subscription? {
        activeSubscriptions.max { $0.monthlyAmount < $1.monthlyAmount }
    }

    var categoryTotals: [(category: SubscriptionCategory, total: Decimal)] {
        var totals: [SubscriptionCategory: Decimal] = [:]
        for sub in activeSubscriptions {
            totals[sub.category, default: .zero] += sub.monthlyAmount
        }
        return totals.map { (category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    func fetchSubscriptions() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Subscription>(sortBy: [SortDescriptor(\.nextChargeDate)])
        subscriptions = (try? context.fetch(descriptor)) ?? []

        for sub in subscriptions {
            sub.advanceNextChargeDate()
        }
    }

    func addSubscription(_ subscription: Subscription) {
        modelContext?.insert(subscription)
        try? modelContext?.save()
        fetchSubscriptions()
    }

    func deleteSubscription(_ subscription: Subscription) {
        NotificationManager.shared.cancelNotification(for: subscription.id)
        modelContext?.delete(subscription)
        try? modelContext?.save()
        fetchSubscriptions()
    }

    func saveChanges() {
        try? modelContext?.save()
        fetchSubscriptions()
    }
}
