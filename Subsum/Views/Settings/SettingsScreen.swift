import SwiftUI
import UniformTypeIdentifiers

struct SettingsScreen: View {
    @Environment(SettingsViewModel.self) private var settingsVM
    @Environment(SubscriptionViewModel.self) private var subscriptionVM
    @State private var showPaywall = false
    @State private var showExportSheet = false
    @State private var csvURL: URL?

    var body: some View {
        NavigationStack {
            List {
                generalSection
                notificationSection
                proFeaturesSection
                aboutSection
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = csvURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    @ViewBuilder
    private var generalSection: some View {
        @Bindable var vm = settingsVM
        Section("General") {
            Picker("Currency", selection: $vm.currency) {
                ForEach(CurrencyOption.all) { option in
                    Text("\(option.symbol) \(option.name)").tag(option.code)
                }
            }
        }
    }

    @ViewBuilder
    private var notificationSection: some View {
        @Bindable var vm = settingsVM
        Section("Notifications") {
            Toggle("Reminders", isOn: $vm.notificationsEnabled)
                .onChange(of: vm.notificationsEnabled) { _, enabled in
                    if enabled {
                        Task { await NotificationManager.shared.requestAuthorization() }
                        NotificationManager.shared.rescheduleAll(
                            subscriptions: subscriptionVM.activeSubscriptions,
                            reminderDays: settingsVM.defaultReminderDays
                        )
                    }
                }

            if settingsVM.isProUser {
                Picker("Remind Before", selection: $vm.defaultReminderDays) {
                    ForEach(1...7, id: \.self) { days in
                        Text("\(days) day\(days == 1 ? "" : "s") before").tag(days)
                    }
                }
                .onChange(of: vm.defaultReminderDays) { _, newValue in
                    NotificationManager.shared.rescheduleAll(
                        subscriptions: subscriptionVM.activeSubscriptions,
                        reminderDays: newValue
                    )
                }
            } else {
                HStack {
                    Text("Custom Reminder Timing")
                    Spacer()
                    ProBadge()
                }
                .onTapGesture { showPaywall = true }
            }
        }
    }

    @ViewBuilder
    private var proFeaturesSection: some View {
        Section("Pro Features") {
            if settingsVM.isProUser {
                @Bindable var vm = settingsVM
                Toggle("\(BiometricManager.shared.biometricName) Lock", isOn: $vm.biometricLockEnabled)

                Button("Export CSV") {
                    exportCSV()
                }

                Button("Manage Subscription") {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upgrade to Pro")
                                .fontWeight(.medium)
                            Text("Unlock all features with a 7-day free trial")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            Button("Privacy Policy") {}
            Button("Restore Purchases") {
                Task { await PurchaseManager.shared.restorePurchases() }
            }
        }
    }

    #if DEBUG
    @ViewBuilder
    private var debugSection: some View {
        @Bindable var vm = settingsVM
        Section {
            Toggle("God Mode (Pro)", isOn: $vm.isProUser)

            Button("Reset Onboarding") {
                settingsVM.hasCompletedOnboarding = false
            }

            Button("Add Sample Subscriptions") {
                addSampleData()
            }

            Button("Clear All Subscriptions", role: .destructive) {
                for sub in subscriptionVM.subscriptions {
                    subscriptionVM.deleteSubscription(sub)
                }
            }
        } header: {
            Label("Debug", systemImage: "ladybug")
        } footer: {
            Text("This section only appears in DEBUG builds and will not ship to the App Store.")
        }
    }

    private func addSampleData() {
        let samples: [(String, Decimal, BillingFrequency, SubscriptionCategory)] = [
            ("Netflix", 15.49, .monthly, .streaming),
            ("Spotify", 9.99, .monthly, .music),
            ("iCloud+", 2.99, .monthly, .cloud),
            ("ChatGPT Plus", 20.00, .monthly, .productivity),
            ("YouTube Premium", 13.99, .monthly, .streaming),
            ("Apple One", 19.95, .monthly, .utilities),
            ("Nintendo Online", 19.99, .yearly, .gaming),
        ]

        for (name, amount, freq, cat) in samples {
            let daysOffset = Int.random(in: 1...28)
            let nextDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: .now) ?? .now
            let sub = Subscription(
                name: name,
                amount: amount,
                currency: settingsVM.currency,
                billingFrequency: freq,
                nextChargeDate: nextDate,
                category: cat
            )
            subscriptionVM.addSubscription(sub)
        }
    }
    #endif

    private func exportCSV() {
        var csv = "Name,Amount,Currency,Frequency,Next Charge,Category\n"
        for sub in subscriptionVM.activeSubscriptions {
            csv += "\"\(sub.name)\",\(sub.amount),\(sub.currency),\(sub.billingFrequency.displayName),\(sub.nextChargeDate.formatted(date: .abbreviated, time: .omitted)),\(sub.category.displayName)\n"
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("subsum_export.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
        csvURL = tempURL
        showExportSheet = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
