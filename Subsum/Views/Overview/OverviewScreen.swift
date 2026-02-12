import SwiftUI

struct OverviewScreen: View {
    @Environment(SubscriptionViewModel.self) private var subscriptionVM
    @Environment(SettingsViewModel.self) private var settingsVM
    @State private var showPaywall = false
    @State private var showAddSubscription = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroSection
                    yearlyProjectionCard
                    upcomingChargesSection

                    if !settingsVM.isProUser {
                        upgradeTeaseCard
                    }
                }
                .padding()
            }
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSubscription) {
                AddSubscriptionView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onAppear {
                subscriptionVM.fetchSubscriptions()
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 4) {
            Text(subscriptionVM.monthlyTotal.formatted(currencyCode: settingsVM.currency))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text("/month")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var yearlyProjectionCard: some View {
        Button {
            if !settingsVM.isProUser {
                showPaywall = true
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Yearly Projection")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if settingsVM.isProUser {
                        Text(subscriptionVM.yearlyProjection.formatted(currencyCode: settingsVM.currency))
                            .font(.title2)
                            .fontWeight(.semibold)
                    } else {
                        Text(subscriptionVM.yearlyProjection.formatted(currencyCode: settingsVM.currency))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .blur(radius: 8)
                            .overlay {
                                if subscriptionVM.activeSubscriptions.count >= 3 {
                                    Label("Tap to unlock", systemImage: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                    }
                }
                Spacer()
                if !settingsVM.isProUser {
                    ProBadge()
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var upcomingChargesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Charges")
                .font(.headline)

            let upcoming = Array(subscriptionVM.upcomingCharges.prefix(5))

            if upcoming.isEmpty {
                Text("No upcoming charges")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(upcoming, id: \.id) { sub in
                    UpcomingChargeRow(subscription: sub, currency: settingsVM.currency)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var upgradeTeaseCard: some View {
        Button {
            showPaywall = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock yearly insights & advanced reminders")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Start your 7-day free trial")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct UpcomingChargeRow: View {
    let subscription: Subscription
    let currency: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.category.iconName)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(SubsumColors.forCategory(subscription.category).opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(SubsumColors.forCategory(subscription.category))

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(daysText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(subscription.amount.formatted(currencyCode: currency))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private var daysText: String {
        let days = subscription.daysUntilNextCharge
        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "in \(days) days"
        }
    }
}
