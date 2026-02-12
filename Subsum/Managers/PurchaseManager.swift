import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    private(set) var products: [Product] = []
    private(set) var isPro = false
    private(set) var isLoading = false

    static let monthlyProductID = "com.hasoo.subsum.pro.monthly"
    static let yearlyProductID = "com.hasoo.subsum.pro.yearly"

    private var updateTask: Task<Void, Never>?

    private init() {
        updateTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
    }

    deinit {
        updateTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [
                Self.monthlyProductID,
                Self.yearlyProductID,
            ])
        } catch {
            products = []
        }
        isLoading = false
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlementStatus()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func refreshEntitlementStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.monthlyProductID || transaction.productID == Self.yearlyProductID {
                    isPro = true
                    return
                }
            }
        }
        isPro = false
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlementStatus()
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await refreshEntitlementStatus()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyProductID }
    }

    enum StoreError: LocalizedError {
        case verificationFailed
        var errorDescription: String? { "Transaction verification failed." }
    }
}
