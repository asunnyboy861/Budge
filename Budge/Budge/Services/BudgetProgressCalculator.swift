import Foundation

struct BudgetProgress {
    let spent: Decimal
    let budget: Decimal
    let percentage: Double
    let daysElapsed: Int
    let totalDays: Int
    let status: BudgetStatus
    let encouragementText: String

    enum BudgetStatus {
        case great, onTrack, caution, over

        var colorName: String {
            switch self {
            case .great, .onTrack: return "BudgetGreen"
            case .caution, .over: return "BudgetOrange"
            }
        }
    }

    static func calculate(spent: Decimal, budget: Decimal, daysElapsed: Int, totalDaysInMonth: Int) -> BudgetProgress {
        let percentage = budget > 0 ? Double(truncating: (spent / budget * 100) as NSNumber) : 0

        let status: BudgetStatus
        let encouragement: String

        if percentage <= 50 {
            status = .great
            encouragement = "Looking great! \(CurrencyFormatter.format(budget - spent)) left this month"
        } else if percentage <= 75 {
            status = .onTrack
            encouragement = "On track! \(CurrencyFormatter.format(budget - spent)) left"
        } else if percentage <= 100 {
            status = .caution
            encouragement = "Heads up, \(CurrencyFormatter.format(budget - spent)) left for the month"
        } else {
            status = .over
            let overAmount = spent - budget
            encouragement = "Over by \(CurrencyFormatter.format(overAmount)), but you can adjust!"
        }

        return BudgetProgress(
            spent: spent,
            budget: budget,
            percentage: percentage,
            daysElapsed: daysElapsed,
            totalDays: totalDaysInMonth,
            status: status,
            encouragementText: encouragement
        )
    }
}
