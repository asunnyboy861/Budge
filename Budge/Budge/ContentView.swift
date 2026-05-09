import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var settings: [AppSetting]
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if let setting = settings.first, setting.hasCompletedOnboarding {
                mainTabView
            } else {
                WelcomeView()
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
                .tag(0)

            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Budget.self, AppSetting.self], inMemory: true)
}
