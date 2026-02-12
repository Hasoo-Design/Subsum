import Foundation
import SwiftData

enum BillingFrequency: String, Codable, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    var monthlyMultiplier: Decimal {
        switch self {
        case .weekly: Decimal(52) / Decimal(12)
        case .monthly: 1
        case .yearly: Decimal(1) / Decimal(12)
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly: .weekOfYear
        case .monthly: .month
        case .yearly: .year
        }
    }
}

enum SubscriptionCategory: String, Codable, CaseIterable, Identifiable {
    case streaming
    case music
    case cloud
    case productivity
    case gaming
    case news
    case fitness
    case education
    case utilities
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .streaming: "Streaming"
        case .music: "Music"
        case .cloud: "Cloud"
        case .productivity: "Productivity"
        case .gaming: "Gaming"
        case .news: "News"
        case .fitness: "Fitness"
        case .education: "Education"
        case .utilities: "Utilities"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .streaming: "play.tv"
        case .music: "music.note"
        case .cloud: "cloud"
        case .productivity: "briefcase"
        case .gaming: "gamecontroller"
        case .news: "newspaper"
        case .fitness: "figure.run"
        case .education: "book"
        case .utilities: "wrench.and.screwdriver"
        case .other: "square.grid.2x2"
        }
    }

    var color: String {
        switch self {
        case .streaming: "categoryStreaming"
        case .music: "categoryMusic"
        case .cloud: "categoryCloud"
        case .productivity: "categoryProductivity"
        case .gaming: "categoryGaming"
        case .news: "categoryNews"
        case .fitness: "categoryFitness"
        case .education: "categoryEducation"
        case .utilities: "categoryUtilities"
        case .other: "categoryOther"
        }
    }
}

@Model
final class Subscription {
    var id: UUID
    var name: String
    var amount: Decimal
    var currency: String
    var billingFrequencyRaw: String
    var nextChargeDate: Date
    var categoryRaw: String
    var createdAt: Date
    var isActive: Bool

    var billingFrequency: BillingFrequency {
        get { BillingFrequency(rawValue: billingFrequencyRaw) ?? .monthly }
        set { billingFrequencyRaw = newValue.rawValue }
    }

    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var monthlyAmount: Decimal {
        amount * billingFrequency.monthlyMultiplier
    }

    var yearlyAmount: Decimal {
        monthlyAmount * 12
    }

    var daysUntilNextCharge: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: nextChargeDate)).day ?? 0
    }

    init(
        name: String,
        amount: Decimal,
        currency: String = "USD",
        billingFrequency: BillingFrequency = .monthly,
        nextChargeDate: Date,
        category: SubscriptionCategory = .other,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.currency = currency
        self.billingFrequencyRaw = billingFrequency.rawValue
        self.nextChargeDate = nextChargeDate
        self.categoryRaw = category.rawValue
        self.createdAt = .now
        self.isActive = isActive
    }

    func advanceNextChargeDate() {
        guard nextChargeDate < .now else { return }
        var date = nextChargeDate
        let calendar = Calendar.current
        while date < .now {
            guard let next = calendar.date(byAdding: billingFrequency.calendarComponent, value: 1, to: date) else { break }
            date = next
        }
        nextChargeDate = date
    }
}
