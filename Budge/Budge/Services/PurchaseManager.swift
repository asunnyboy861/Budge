import Foundation
import StoreKit

typealias StoreTransaction = StoreKit.Transaction

@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false

    private var transactionListener: Task<Void, Never>?

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
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: [Constants.monthlyProductId, Constants.yearlyProductId])
            products = storeProducts
            await updatePurchasedProducts()
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async -> Bool {
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
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {}
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in StoreTransaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    self.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
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

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
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
