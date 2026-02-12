import SwiftUI

struct AddSubscriptionView: View {
    @Environment(SubscriptionViewModel.self) private var subscriptionVM
    @Environment(SettingsViewModel.self) private var settingsVM
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amountText = ""
    @State private var billingFrequency: BillingFrequency = .monthly
    @State private var nextChargeDate = Date()
    @State private var category: SubscriptionCategory = .other

    var editingSubscription: Subscription?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Price", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Picker("Billing Frequency", selection: $billingFrequency) {
                        ForEach(BillingFrequency.allCases) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    DatePicker("Next Charge Date", selection: $nextChargeDate, displayedComponents: .date)
                }

                Section {
                    Picker("Category", selection: $category) {
                        ForEach(SubscriptionCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.iconName).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle(editingSubscription == nil ? "Add Subscription" : "Edit Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty || amountText.isEmpty)
                }
            }
            .onAppear {
                if let sub = editingSubscription {
                    name = sub.name
                    amountText = "\(sub.amount)"
                    billingFrequency = sub.billingFrequency
                    nextChargeDate = sub.nextChargeDate
                    category = sub.category
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }

        if let sub = editingSubscription {
            sub.name = name
            sub.amount = amount
            sub.billingFrequency = billingFrequency
            sub.nextChargeDate = nextChargeDate
            sub.category = category
            subscriptionVM.saveChanges()

            if settingsVM.notificationsEnabled {
                NotificationManager.shared.scheduleNotification(for: sub, reminderDays: settingsVM.defaultReminderDays)
            }
        } else {
            let sub = Subscription(
                name: name,
                amount: amount,
                currency: settingsVM.currency,
                billingFrequency: billingFrequency,
                nextChargeDate: nextChargeDate,
                category: category
            )
            subscriptionVM.addSubscription(sub)

            if settingsVM.notificationsEnabled {
                Task { await NotificationManager.shared.requestAuthorization() }
                NotificationManager.shared.scheduleNotification(for: sub, reminderDays: settingsVM.defaultReminderDays)
            }
        }

        dismiss()
    }
}
