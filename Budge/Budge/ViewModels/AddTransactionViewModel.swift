import SwiftUI
import SwiftData

@Observable
final class AddTransactionViewModel {
    var amountText = "0"
    var selectedType: Transaction.TransactionType = .expense
    var selectedCategory: CategoryItem?
    var note = ""

    var canSave: Bool {
        let amount = Decimal(string: amountText) ?? 0
        return amount > 0 && selectedCategory != nil
    }

    var expenseCategories: [CategoryItem] {
        Constants.Category.expenseCategories.map { CategoryItem(name: $0.name, icon: $0.icon, type: .expense) }
    }

    var incomeCategories: [CategoryItem] {
        Constants.Category.incomeCategories.map { CategoryItem(name: $0.name, icon: $0.icon, type: .income) }
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
