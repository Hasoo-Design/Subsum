import SwiftUI

enum SubsumColors {
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let accent = Color("AccentColor")
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)

    static let categoryStreaming = Color.red.opacity(0.8)
    static let categoryMusic = Color.pink.opacity(0.8)
    static let categoryCloud = Color.blue.opacity(0.8)
    static let categoryProductivity = Color.orange.opacity(0.8)
    static let categoryGaming = Color.purple.opacity(0.8)
    static let categoryNews = Color.gray.opacity(0.8)
    static let categoryFitness = Color.green.opacity(0.8)
    static let categoryEducation = Color.indigo.opacity(0.8)
    static let categoryUtilities = Color.teal.opacity(0.8)
    static let categoryOther = Color.gray.opacity(0.6)

    static func forCategory(_ category: SubscriptionCategory) -> Color {
        switch category {
        case .streaming: categoryStreaming
        case .music: categoryMusic
        case .cloud: categoryCloud
        case .productivity: categoryProductivity
        case .gaming: categoryGaming
        case .news: categoryNews
        case .fitness: categoryFitness
        case .education: categoryEducation
        case .utilities: categoryUtilities
        case .other: categoryOther
        }
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundStyle(.secondary)
    }
}

extension Decimal {
    func formatted(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}
