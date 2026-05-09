import Foundation
import SwiftData

struct CSVExportService {
    static func export(transactions: [Transaction], currencyCode: String = "USD") -> URL? {
        var csv = "Date,Type,Category,Amount,Note\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for t in transactions.sorted(by: { $0.date > $1.date }) {
            let dateStr = formatter.string(from: t.date)
            let typeStr = t.type.rawValue
            let amountStr = String(describing: t.amount)
            let noteStr = t.note.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\(dateStr),\(typeStr),\(t.categoryName),\(amountStr),\"\(noteStr)\"\n"
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Budge_Export_\(formatter.string(from: .now)).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}
