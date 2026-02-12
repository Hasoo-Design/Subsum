import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SettingsViewModel.self) private var settingsVM
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private let purchaseManager = PurchaseManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    featuresSection
                    pricingSection
                    purchaseButton
                    footerSection
                }
                .padding()
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                await purchaseManager.loadProducts()
                selectedProduct = purchaseManager.yearlyProduct
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(.yellow)

            Text("Upgrade Your\nFinancial Clarity")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Start your 7-day free trial")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            featureRow(icon: "chart.line.uptrend.xyaxis", title: "Yearly Projection", subtitle: "See your full annual spending")
            featureRow(icon: "chart.pie", title: "Advanced Insights", subtitle: "Category breakdowns & trends")
            featureRow(icon: "bell.badge", title: "Custom Reminders", subtitle: "Choose 1–7 days before charges")
            featureRow(icon: "faceid", title: "Biometric Lock", subtitle: "Protect your data with Face ID")
            featureRow(icon: "arrow.down.doc", title: "CSV Export", subtitle: "Export your subscription data")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 32, height: 32)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if let yearly = purchaseManager.yearlyProduct {
                pricingCard(product: yearly, recommended: true)
            }
            if let monthly = purchaseManager.monthlyProduct {
                pricingCard(product: monthly, recommended: false)
            }

            if purchaseManager.products.isEmpty && !purchaseManager.isLoading {
                Text("Products unavailable — try Restore Purchases")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func pricingCard(product: Product, recommended: Bool) -> some View {
        Button {
            selectedProduct = product
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(product.id == PurchaseManager.yearlyProductID ? "Yearly" : "Monthly")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if recommended {
                            Text("Save 33%")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.green.opacity(0.3), in: Capsule())
                        }
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(product.displayPrice)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(product.id == PurchaseManager.yearlyProductID ? "/year" : "/month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: selectedProduct?.id == product.id ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selectedProduct?.id == product.id ? .white : .secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedProduct?.id == product.id ? Color.white : .clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        Button {
            purchase()
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                } else {
                    Text("Start Free Trial")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(.white)
        .foregroundStyle(.black)
        .disabled(selectedProduct == nil || isPurchasing)
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            Button("Restore Purchases") {
                Task {
                    await purchaseManager.restorePurchases()
                    if purchaseManager.isPro {
                        settingsVM.isProUser = true
                        dismiss()
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("7-day free trial, then auto-renews.\nCancel anytime in Settings.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private func purchase() {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let success = try await purchaseManager.purchase(product)
                if success {
                    settingsVM.isProUser = true
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isPurchasing = false
        }
    }
}
