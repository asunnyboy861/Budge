import Foundation
import StoreKit

typealias StoreTransaction = StoreKit.Transaction

@Observable
@MainActor
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var purchaseError: String?
    var loadError: String?

    private var transactionListener: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?

    var isPro: Bool {
        purchasedProductIDs.contains(Constants.monthlyProductId) ||
        purchasedProductIDs.contains(Constants.yearlyProductId)
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Constants.monthlyProductId }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Constants.yearlyProductId }
    }

    init() {
        transactionListener = listenForTransactions()
        updateTask = Task {
            await loadProducts()
        }
    }

    nonisolated deinit {
        _ = Task { @MainActor [weak self] in
            self?.transactionListener?.cancel()
            self?.updateTask?.cancel()
        }
    }

    func loadProducts() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let productIDs: Set<String> = [Constants.monthlyProductId, Constants.yearlyProductId]
        print("[PurchaseManager] Loading products: \(productIDs)")

        do {
            let storeProducts = try await Product.products(for: productIDs)
            print("[PurchaseManager] Loaded \(storeProducts.count) products successfully")
            for product in storeProducts {
                print("[PurchaseManager]   - \(product.id): \(product.displayName) @ \(product.displayPrice)")
            }
            products = storeProducts

            if storeProducts.isEmpty {
                loadError = "No products found. Please check that In-App Purchase products are configured in App Store Connect."
                print("[PurchaseManager] WARNING: No products returned from StoreKit")
            }

            await updatePurchasedProducts()
        } catch {
            loadError = "Failed to load products: \(error.localizedDescription)"
            print("[PurchaseManager] ERROR loading products: \(error)")
            products = []
        }
    }

    func purchase(_ product: Product) async -> Bool {
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                return true

            case .userCancelled:
                return false

            case .pending:
                purchaseError = "Your purchase is pending approval."
                return false

            @unknown default:
                purchaseError = "Unknown purchase result."
                return false
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return isPro
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
            return false
        }
    }

    private nonisolated func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in StoreTransaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    } as Void
                    _ = await transaction.finish()
                } catch {}
            }
        }
    }

    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in StoreTransaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
            } catch {}
        }

        purchasedProductIDs = purchasedIDs
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
