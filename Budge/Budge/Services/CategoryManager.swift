import Foundation
import SwiftData

struct CategoryManager {
    static func getAllCategories(
        type: Transaction.TransactionType,
        customCategories: [CustomCategory],
        isPro: Bool
    ) -> [CategoryItem] {
        var categories: [CategoryItem] = []
        
        let presetCategories = type == .expense
            ? Constants.Category.expenseCategories
            : Constants.Category.incomeCategories
        
        categories = presetCategories.map {
            CategoryItem(name: $0.name, icon: $0.icon, type: type)
        }
        
        if isPro {
            let custom = customCategories
                .filter { $0.type == type }
                .map { CategoryItem(name: $0.name, icon: $0.icon, type: $0.type) }
            categories.append(contentsOf: custom)
        }
        
        return categories
    }
    
    static func addCustomCategory(
        name: String,
        icon: String,
        type: Transaction.TransactionType,
        context: ModelContext
    ) -> CustomCategory? {
        let category = CustomCategory(name: name, icon: icon, type: type)
        context.insert(category)
        return category
    }
    
    static func deleteCustomCategory(_ category: CustomCategory, context: ModelContext) {
        context.delete(category)
    }
}
