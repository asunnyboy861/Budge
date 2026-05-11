import Foundation
import SwiftData

enum iCloudSyncService {
    static func createModelContainer(iCloudEnabled: Bool) -> ModelContainer {
        let schema = Schema([
            Transaction.self,
            Budget.self,
            AppSetting.self,
            CustomCategory.self
        ])
        
        let configuration: ModelConfiguration
        
        if iCloudEnabled {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .identifier("iCloud.com.zzoutuo.Budge"),
                cloudKitDatabase: .private("iCloud.com.zzoutuo.Budge")
            )
        } else {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .none,
                cloudKitDatabase: .none
            )
        }
        
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    static func migrateToiCloud(from localContainer: ModelContainer) async throws {
        let localContext = localContainer.mainContext
        
        let transactions = try localContext.fetch(FetchDescriptor<Transaction>())
        let budgets = try localContext.fetch(FetchDescriptor<Budget>())
        let settings = try localContext.fetch(FetchDescriptor<AppSetting>())
        let categories = try localContext.fetch(FetchDescriptor<CustomCategory>())
        
        let iCloudContainer = createModelContainer(iCloudEnabled: true)
        let iCloudContext = iCloudContainer.mainContext
        
        for transaction in transactions {
            iCloudContext.insert(transaction)
        }
        
        for budget in budgets {
            iCloudContext.insert(budget)
        }
        
        for setting in settings {
            iCloudContext.insert(setting)
        }
        
        for category in categories {
            iCloudContext.insert(category)
        }
        
        try iCloudContext.save()
    }
}
