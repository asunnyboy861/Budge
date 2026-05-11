import SwiftUI
import SwiftData

@Observable
final class TodayViewModel {
    var budgetProgress: BudgetProgress?
    var recentTransactions: [Transaction] = []
    var insights: [TrendData.TrendInsight] = []
    var currencyCode = "USD"

    var currentDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: .now)
    }

    func load(expenses: [Transaction], budgets: [Budget], settings: [AppSetting]) {
        let setting = settings.first
        currencyCode = setting?.currencyCode ?? "USD"

        let startOfMonth = DateHelper.startOfMonth()
        let daysElapsed = DateHelper.daysElapsedInMonth()
        let totalDays = DateHelper.totalDaysInMonth()

        let monthExpenses = expenses.filter { $0.date >= startOfMonth }
        let totalSpent = monthExpenses.reduce(Decimal(0)) { $0 + $1.amount }

        if let budget = budgets.first {
            budgetProgress = BudgetProgress.calculate(
                spent: totalSpent,
                budget: budget.totalAmount,
                daysElapsed: daysElapsed,
                totalDaysInMonth: totalDays
            )
        }

        recentTransactions = Array(expenses.sorted { $0.date > $1.date }.prefix(5))

        if !expenses.isEmpty {
            let trendData = TrendCalculator.calculate(transactions: expenses)
            insights = trendData.insights
        }
    }
}
