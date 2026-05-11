import SwiftUI
import SwiftData

@Observable
final class AddTransactionViewModel {
    var amountText = "0"
    var selectedType: Transaction.TransactionType = .expense
    var selectedCategory: CategoryItem?
    var note = ""
    var currencyCode = "USD"
    var isPro = false
    var customCategories: [CustomCategory] = []

    var canSave: Bool {
        let amount = Decimal(string: amountText) ?? 0
        return amount > 0 && selectedCategory != nil
    }

    var expenseCategories: [CategoryItem] {
        CategoryManager.getAllCategories(
            type: .expense,
            customCategories: customCategories,
            isPro: isPro
        )
    }

    var incomeCategories: [CategoryItem] {
        CategoryManager.getAllCategories(
            type: .income,
            customCategories: customCategories,
            isPro: isPro
        )
    }

    var currentCategories: [CategoryItem] {
        selectedType == .expense ? expenseCategories : incomeCategories
    }

    func save(context: ModelContext) -> Transaction? {
        guard let category = selectedCategory,
              let amount = Decimal(string: amountText), amount > 0 else { return nil }

        let transaction = Transaction(
            amount: amount,
            type: selectedType,
            categoryName: category.name,
            categoryIcon: category.icon,
            note: note
        )
        context.insert(transaction)
        return transaction
    }

    func reset() {
        amountText = "0"
        selectedType = .expense
        selectedCategory = nil
        note = ""
    }
}

struct CategoryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let type: Transaction.TransactionType
}
