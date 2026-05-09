import SwiftUI
import SwiftData

@Observable
final class TrendsViewModel {
    var trendData: TrendData?
    var selectedPeriod = 90
    var currencyCode = "USD"

    func load(transactions: [Transaction], settings: [AppSetting]) {
        currencyCode = settings.first?.currencyCode ?? "USD"

        let expenses = transactions.filter { $0.type == .expense }
        if !expenses.isEmpty {
            trendData = TrendCalculator.calculate(transactions: expenses)
        }
    }
}
