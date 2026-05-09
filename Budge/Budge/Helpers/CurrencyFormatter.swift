import Foundation

struct CurrencyFormatter {
    static func format(_ value: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: value as NSNumber) ?? "$0.00"
    }

    static func formatCompact(_ value: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}
