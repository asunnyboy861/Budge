import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var currencyCode = "USD"
    var reminderEnabled = true
    var reminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
    var biometricEnabled = false
    var iCloudSyncEnabled = true
    var isPro = false

    func load(settings: [AppSetting], purchaseManager: PurchaseManager) {
        if let setting = settings.first {
            currencyCode = setting.currencyCode
            reminderEnabled = setting.reminderEnabled
            reminderTime = setting.reminderTime
            biometricEnabled = setting.biometricEnabled
            iCloudSyncEnabled = setting.iCloudSyncEnabled
        }
        isPro = purchaseManager.isPro
    }

    func save(context: ModelContext, settings: [AppSetting]) {
        let setting = settings.first ?? AppSetting()
        setting.currencyCode = currencyCode
        setting.reminderEnabled = reminderEnabled
        setting.reminderTime = reminderTime
        setting.biometricEnabled = biometricEnabled
        setting.iCloudSyncEnabled = iCloudSyncEnabled

        if !settings.contains(where: { $0.id == setting.id }) {
            context.insert(setting)
        }

        Task {
            await NotificationService.scheduleDailyReminder(at: reminderTime, enabled: reminderEnabled)
        }
    }
}
