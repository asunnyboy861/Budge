import Foundation
import SwiftData

@Model
final class AppSetting {
    @Attribute(.unique) var id: UUID
    var currencyCode: String
    var reminderEnabled: Bool
    var reminderTime: Date
    var biometricEnabled: Bool
    var iCloudSyncEnabled: Bool
    var hasCompletedOnboarding: Bool

    init(
        currencyCode: String = "USD",
        reminderEnabled: Bool = true,
        reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now,
        biometricEnabled: Bool = false,
        iCloudSyncEnabled: Bool = true,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = UUID()
        self.currencyCode = currencyCode
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.biometricEnabled = biometricEnabled
        self.iCloudSyncEnabled = iCloudSyncEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
