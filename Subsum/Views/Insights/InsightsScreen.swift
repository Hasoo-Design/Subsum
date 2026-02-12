import SwiftUI
import Charts

struct InsightsScreen: View {
    @Environment(SubscriptionViewModel.self) private var subscriptionVM
    @Environment(SettingsViewModel.self) private var settingsVM
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if settingsVM.isProUser {
                    proInsights
                } else {
                    lockedInsights
                }
            }
            .navigationTitle("Insights")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var lockedInsights: some View {
        VStack(spacing: 24) {
            categoryChartPreview
                .blur(radius: 6)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.title)
                        Text("Unlock Insights")
                            .font(.headline)
                        Text("See where your money goes with\ncategory breakdowns and trends.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Start Free Trial") {
                            showPaywall = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                    }
                }
                .frame(minHeight: 400)
        }
        .padding()
    }

    private var proInsights: some View {
        VStack(spacing: 20) {
            categoryBreakdownSection
            mostExpensiveSection
            monthlyTrendSection
        }
        .padding()
    }

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)

            if subscriptionVM.categoryTotals.isEmpty {
                Text("Add subscriptions to see breakdown")
                    .foregroundStyle(.secondary)
            } else {
                Chart(subscriptionVM.categoryTotals, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", NSDecimalNumber(decimal: item.total).doubleValue),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(SubsumColors.forCategory(item.category))
                    .cornerRadius(4)
                }
                .frame(height: 220)

                ForEach(subscriptionVM.categoryTotals, id: \.category) { item in
                    HStack {
                        Circle()
                            .fill(SubsumColors.forCategory(item.category))
                            .frame(width: 10, height: 10)
                        Text(item.category.displayName)
                            .font(.subheadline)
                        Spacer()
                        Text(item.total.formatted(currencyCode: settingsVM.currency))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("/mo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var mostExpensiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Expensive")
                .font(.headline)

            if let top = subscriptionVM.mostExpensive {
                HStack(spacing: 12) {
                    Image(systemName: top.category.iconName)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(SubsumColors.forCategory(top.category).opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(SubsumColors.forCategory(top.category))

                    VStack(alignment: .leading) {
                        Text(top.name)
                            .font(.body)
                            .fontWeight(.medium)
                        Text(top.billingFrequency.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(top.monthlyAmount.formatted(currencyCode: settingsVM.currency))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("/month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("No subscriptions yet")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var monthlyTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Spending")
                .font(.headline)

            let data = monthlyTrendData

            if data.isEmpty {
                Text("Add subscriptions to see trends")
                    .foregroundStyle(.secondary)
            } else {
                Chart(data, id: \.month) { item in
                    BarMark(
                        x: .value("Month", item.month, unit: .month),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(.white.opacity(0.6))
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var categoryChartPreview: some View {
        VStack(spacing: 16) {
            Chart {
                SectorMark(angle: .value("A", 40), innerRadius: .ratio(0.6), angularInset: 2)
                    .foregroundStyle(.red.opacity(0.6))
                SectorMark(angle: .value("B", 25), innerRadius: .ratio(0.6), angularInset: 2)
                    .foregroundStyle(.blue.opacity(0.6))
                SectorMark(angle: .value("C", 20), innerRadius: .ratio(0.6), angularInset: 2)
                    .foregroundStyle(.green.opacity(0.6))
                SectorMark(angle: .value("D", 15), innerRadius: .ratio(0.6), angularInset: 2)
                    .foregroundStyle(.purple.opacity(0.6))
            }
            .frame(height: 220)

            Chart {
                ForEach(0..<6, id: \.self) { i in
                    BarMark(
                        x: .value("Month", i),
                        y: .value("Amount", Double.random(in: 100...250))
                    )
                    .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(height: 120)
        }
    }

    private var monthlyTrendData: [(month: Date, amount: Double)] {
        let calendar = Calendar.current
        let now = Date.now
        return (0..<6).compactMap { monthsAgo in
            guard let month = calendar.date(byAdding: .month, value: -monthsAgo, to: now) else { return nil }
            let total = subscriptionVM.activeSubscriptions.reduce(0.0) { sum, sub in
                guard sub.createdAt <= month else { return sum }
                return sum + NSDecimalNumber(decimal: sub.monthlyAmount).doubleValue
            }
            return (month: month, amount: total)
        }.reversed()
    }
}
