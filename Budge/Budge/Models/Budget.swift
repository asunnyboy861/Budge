import Foundation
import SwiftData

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var totalAmount: Decimal
    var period: BudgetPeriod
    var createdAt: Date

    enum BudgetPeriod: String, Codable {
        case monthly
        case yearly
    }

    init(totalAmount: Decimal, period: BudgetPeriod = .monthly) {
        self.id = UUID()
        self.totalAmount = totalAmount
        self.period = period
        self.createdAt = .now
    }
}
