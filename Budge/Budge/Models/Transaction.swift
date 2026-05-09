import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var type: TransactionType
    var categoryName: String
    var categoryIcon: String
    var note: String
    var date: Date

    enum TransactionType: String, Codable, CaseIterable {
        case expense
        case income
    }

    init(
        amount: Decimal,
        type: TransactionType,
        categoryName: String,
        categoryIcon: String,
        note: String = "",
        date: Date = .now
    ) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
        self.note = note
        self.date = date
    }
}
