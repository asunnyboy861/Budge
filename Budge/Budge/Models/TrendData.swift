import Foundation

struct TrendData {
    let dailySpending: [DailyPoint]
    let movingAverage: [Decimal]
    let categoryTrends: [CategoryTrend]
    let monthOverMonth: Double
    let direction: TrendDirection
    let insights: [TrendInsight]

    struct DailyPoint: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Decimal
    }

    struct CategoryTrend: Identifiable {
        let id = UUID()
        let categoryName: String
        let categoryIcon: String
        let currentMonth: Decimal
        let lastMonth: Decimal
        let changePercentage: Double
        let direction: TrendDirection
    }

    struct TrendInsight: Identifiable {
        let id = UUID()
        let emoji: String
        let text: String
        let actionSuggestion: String?
    }

    enum TrendDirection {
        case up, down, flat
    }
}
