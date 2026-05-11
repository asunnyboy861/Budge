import SwiftUI
import SwiftData

@main
struct BudgeApp: App {
    let modelContainer: ModelContainer
    @State private var purchaseManager = PurchaseManager()

    init() {
        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        modelContainer = iCloudSyncService.createModelContainer(iCloudEnabled: iCloudEnabled)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
        }
        .modelContainer(modelContainer)
    }
}
