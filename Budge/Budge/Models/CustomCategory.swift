import Foundation
import SwiftData

@Model
final class CustomCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var type: Transaction.TransactionType
    var createdAt: Date
    
    init(name: String, icon: String, type: Transaction.TransactionType) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.type = type
        self.createdAt = .now
    }
}
