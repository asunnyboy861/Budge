import SwiftUI
import SwiftData

@main
struct BudgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Budget.self, AppSetting.self])
    }
}
