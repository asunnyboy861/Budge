import Foundation

struct DateHelper {
    static let calendar = Calendar.current

    static func startOfMonth(for date: Date = .now) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }

    static func startOfPreviousMonth(for date: Date = .now) -> Date {
        calendar.date(byAdding: .month, value: -1, to: startOfMonth(for: date))!
    }

    static func daysElapsedInMonth(for date: Date = .now) -> Int {
        calendar.dateComponents([.day], from: startOfMonth(for: date), to: date).day ?? 0
    }

    static func totalDaysInMonth(for date: Date = .now) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    static func daysAgo(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: -days, to: .now)!
    }
}
