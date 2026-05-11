import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var currencyCode = "USD"
    var reminderEnabled = true
    var reminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
    var biometricEnabled = false
    var iCloudSyncEnabled = false
    var isPro = false
    var showiCloudRestartAlert = false
    
    func load(settings: [AppSetting], purchaseManager: PurchaseManager) {
        if let setting = settings.first {
            currencyCode = setting.currencyCode
            reminderEnabled = setting.reminderEnabled
            reminderTime = setting.reminderTime
            biometricEnabled = setting.biometricEnabled
            iCloudSyncEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
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
        
        let previousiCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        UserDefaults.standard.set(iCloudSyncEnabled, forKey: "iCloudSyncEnabled")
        
        if previousiCloudEnabled != iCloudSyncEnabled {
            showiCloudRestartAlert = true
        }
        
        Task {
            NotificationService.scheduleDailyReminder(at: reminderTime, enabled: reminderEnabled)
        }
    }
}
