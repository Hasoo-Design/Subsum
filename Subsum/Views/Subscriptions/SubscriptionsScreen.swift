import SwiftUI

struct SubscriptionsScreen: View {
    @Environment(SubscriptionViewModel.self) private var subscriptionVM
    @Environment(SettingsViewModel.self) private var settingsVM
    @State private var showAddSubscription = false
    @State private var editingSubscription: Subscription?

    var body: some View {
        NavigationStack {
            Group {
                if subscriptionVM.activeSubscriptions.isEmpty {
                    ContentUnavailableView(
                        "No Subscriptions",
                        systemImage: "list.bullet",
                        description: Text("Tap + to add your first subscription.")
                    )
                } else {
                    List {
                        ForEach(subscriptionVM.activeSubscriptions, id: \.id) { sub in
                            SubscriptionRow(subscription: sub, currency: settingsVM.currency)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        subscriptionVM.deleteSubscription(sub)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        editingSubscription = sub
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Subscriptions")
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
            .sheet(item: $editingSubscription) { sub in
                AddSubscriptionView(editingSubscription: sub)
            }
            .onAppear {
                subscriptionVM.fetchSubscriptions()
            }
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let currency: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.category.iconName)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(SubsumColors.forCategory(subscription.category).opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(SubsumColors.forCategory(subscription.category))

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(subscription.billingFrequency.displayName) · Next: \(subscription.nextChargeDate, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(subscription.amount.formatted(currencyCode: currency))
                .font(.body)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}
