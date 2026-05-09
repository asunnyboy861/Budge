import Foundation
import SwiftData
import UserNotifications

struct NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(at date: Date, enabled: Bool) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Budge Reminder"
        content.body = "Don't forget to log your expenses today!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
