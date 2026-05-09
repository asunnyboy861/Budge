import Foundation

struct TrendCalculator {
    static func calculate(transactions: [Transaction]) -> TrendData {
        let dailySpending = calculateDailySpending(transactions: transactions)
        let movingAverage = calculateMovingAverage(dailySpending: dailySpending)
        let categoryTrends = calculateCategoryTrends(transactions: transactions)
        let monthOverMonth = calculateMonthOverMonth(transactions: transactions)
        let direction = determineOverallDirection(movingAverage: movingAverage)
        let insights = generateInsights(categoryTrends: categoryTrends, monthOverMonth: monthOverMonth, direction: direction)

        return TrendData(
            dailySpending: dailySpending,
            movingAverage: movingAverage,
            categoryTrends: categoryTrends,
            monthOverMonth: monthOverMonth,
            direction: direction,
            insights: insights
        )
    }

    private static func calculateDailySpending(transactions: [Transaction]) -> [TrendData.DailyPoint] {
        let calendar = Calendar.current
        let startDate = DateHelper.daysAgo(90)
        let filtered = transactions.filter { $0.type == .expense && $0.date >= startDate }

        var dailyMap: [Date: Decimal] = [:]
        for transaction in filtered {
            let dayStart = calendar.startOfDay(for: transaction.date)
            dailyMap[dayStart, default: 0] += transaction.amount
        }

        return (0..<90).compactMap { dayOffset -> TrendData.DailyPoint? in
            guard let date = calendar.date(byAdding: .day, value: -(89 - dayOffset), to: calendar.startOfDay(for: .now)) else { return nil }
            return TrendData.DailyPoint(date: date, amount: dailyMap[date] ?? 0)
        }
    }

    private static func calculateMovingAverage(dailySpending: [TrendData.DailyPoint]) -> [Decimal] {
        let windowSize = 7
        var result: [Decimal] = []
        for i in 0..<dailySpending.count {
            let start = max(0, i - windowSize + 1)
            let window = dailySpending[start...i]
            let avg = window.reduce(Decimal(0)) { $0 + $1.amount } / Decimal(window.count)
            result.append(avg)
        }
        return result
    }

    private static func calculateCategoryTrends(transactions: [Transaction]) -> [TrendData.CategoryTrend] {
        let thisMonthStart = DateHelper.startOfMonth()
        let lastMonthStart = DateHelper.startOfPreviousMonth()

        let thisMonth = transactions.filter { $0.type == .expense && $0.date >= thisMonthStart }
        let lastMonth = transactions.filter { $0.type == .expense && $0.date >= lastMonthStart && $0.date < thisMonthStart }

        let categories = Set(transactions.filter { $0.type == .expense }.map(\.categoryName))

        return categories.compactMap { category in
            let thisAmount = thisMonth.filter { $0.categoryName == category }.reduce(Decimal(0)) { $0 + $1.amount }
            let lastAmount = lastMonth.filter { $0.categoryName == category }.reduce(Decimal(0)) { $0 + $1.amount }

            let change: Double
            if lastAmount > 0 {
                change = Double(truncating: ((thisAmount - lastAmount) / lastAmount) as NSNumber) * 100
            } else {
                change = thisAmount > 0 ? 100 : 0
            }

            let direction: TrendData.TrendDirection
            if change < -5 { direction = .down }
            else if change > 5 { direction = .up }
            else { direction = .flat }

            let icon = transactions.first { $0.categoryName == category }?.categoryIcon ?? "📝"

            return TrendData.CategoryTrend(
                categoryName: category,
                categoryIcon: icon,
                currentMonth: thisAmount,
                lastMonth: lastAmount,
                changePercentage: change,
                direction: direction
            )
        }.sorted { abs($0.changePercentage) > abs($1.changePercentage) }
    }

    private static func calculateMonthOverMonth(transactions: [Transaction]) -> Double {
        let thisMonthStart = DateHelper.startOfMonth()
        let lastMonthStart = DateHelper.startOfPreviousMonth()

        let thisTotal = transactions.filter { $0.type == .expense && $0.date >= thisMonthStart }.reduce(Decimal(0)) { $0 + $1.amount }
        let lastTotal = transactions.filter { $0.type == .expense && $0.date >= lastMonthStart && $0.date < thisMonthStart }.reduce(Decimal(0)) { $0 + $1.amount }

        if lastTotal > 0 {
            return Double(truncating: ((thisTotal - lastTotal) / lastTotal) as NSNumber) * 100
        }
        return 0
    }

    private static func determineOverallDirection(movingAverage: [Decimal]) -> TrendData.TrendDirection {
        guard movingAverage.count >= 14 else { return .flat }
        let recent = movingAverage.suffix(7).reduce(Decimal(0), +) / 7
        let previous = movingAverage.dropLast(7).suffix(7).reduce(Decimal(0), +) / 7

        let change = Double(truncating: ((recent - previous) / max(previous, 1)) as NSNumber) * 100

        if change < -5 { return .down }
        else if change > 5 { return .up }
        else { return .flat }
    }

    private static func generateInsights(
        categoryTrends: [TrendData.CategoryTrend],
        monthOverMonth: Double,
        direction: TrendData.TrendDirection
    ) -> [TrendData.TrendInsight] {
        var insights: [TrendData.TrendInsight] = []

        if direction == .down {
            insights.append(TrendData.TrendInsight(
                emoji: "📉",
                text: "Your spending is trending down! Keep it up!",
                actionSuggestion: nil
            ))
        } else if direction == .up {
            insights.append(TrendData.TrendInsight(
                emoji: "📈",
                text: "Spending is up a bit this month.",
                actionSuggestion: "Review your recent purchases to find easy cuts."
            ))
        }

        let bigDecreases = categoryTrends.filter { $0.changePercentage < -10 }
        for trend in bigDecreases.prefix(2) {
            insights.append(TrendData.TrendInsight(
                emoji: "📉",
                text: "\(trend.categoryName) is down \(abs(Int(trend.changePercentage)))% vs last month. Nice!",
                actionSuggestion: nil
            ))
        }

        let bigIncreases = categoryTrends.filter { $0.changePercentage > 20 }
        for trend in bigIncreases.prefix(1) {
            insights.append(TrendData.TrendInsight(
                emoji: "📈",
                text: "\(trend.categoryName) is up \(Int(trend.changePercentage))%. New expense?",
                actionSuggestion: "Consider if this is a one-time or recurring increase."
            ))
        }

        return insights
    }
}
