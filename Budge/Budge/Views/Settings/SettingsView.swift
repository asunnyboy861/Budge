import SwiftUI
import SwiftData
import StoreKit
import SafariServices

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSetting]
    @Query private var transactions: [Transaction]

    @State private var viewModel = SettingsViewModel()
    @State private var purchaseManager = PurchaseManager()
    @State private var showingPaywall = false
    @State private var showingContactSupport = false
    @State private var exportItem: CSVExportItem?

    var body: some View {
        NavigationStack {
            Form {
                budgetSection
                preferencesSection
                proSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.load(settings: settings, purchaseManager: purchaseManager)
                Task { await purchaseManager.loadProducts() }
            }
        }
    }

    private var budgetSection: some View {
        Section {
            NavigationLink {
                EditBudgetView(budgets: budgetsQuery, currencyCode: viewModel.currencyCode)
            } label: {
                Label("Edit Budget", systemImage: "dollarsign.circle")
            }
        } header: {
            Text("Budget")
        }
    }

    private var preferencesSection: some View {
        Section {
            Picker("Currency", selection: $viewModel.currencyCode) {
                ForEach(["USD", "EUR", "GBP", "CAD", "AUD", "JPY"], id: \.self) {
                    Text($0)
                }
            }

            Toggle("Daily Reminder", isOn: $viewModel.reminderEnabled)

            if viewModel.reminderEnabled {
                DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
            }

            Toggle("Biometric Lock", isOn: $viewModel.biometricEnabled)
                .disabled(!viewModel.isPro)

            Toggle("iCloud Sync", isOn: $viewModel.iCloudSyncEnabled)
        } header: {
            Text("Preferences")
        }
        .onChange(of: viewModel.currencyCode) { saveSettings() }
        .onChange(of: viewModel.reminderEnabled) { saveSettings() }
        .onChange(of: viewModel.reminderTime) { saveSettings() }
        .onChange(of: viewModel.biometricEnabled) { saveSettings() }
        .onChange(of: viewModel.iCloudSyncEnabled) { saveSettings() }
    }

    private var proSection: some View {
        Section {
            if viewModel.isPro {
                Label("Budge Pro Active", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Color("BudgetGreen"))
            } else {
                Button(action: { showingPaywall = true }) {
                    Label("Upgrade to Pro", systemImage: "star.circle")
                        .foregroundStyle(Color("BudgetGreen"))
                }
            }

            Button(action: { Task { await purchaseManager.restorePurchases() } }) {
                Text("Restore Purchases")
            }
        } header: {
            Text("Subscription")
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private var dataSection: some View {
        Section {
            Button(action: exportCSV) {
                Label("Export CSV", systemImage: "square.and.arrow.up")
            }

            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
        } header: {
            Text("Data & Support")
        }
    }

    private var aboutSection: some View {
        Section {
            Link("Privacy Policy", destination: Constants.privacyURL)
            Link("Terms of Use", destination: Constants.termsURL)
            Link("Support", destination: Constants.supportURL)
        } header: {
            Text("Legal")
        }
    }

    private var budgetsQuery: [Budget] {
        let descriptor = FetchDescriptor<Budget>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func saveSettings() {
        viewModel.save(context: modelContext, settings: settings)
    }

    private func exportCSV() {
        guard let url = CSVExportService.export(transactions: transactions, currencyCode: viewModel.currencyCode) else { return }
        exportItem = CSVExportItem(url: url)
    }
}

struct EditBudgetView: View {
    let budgets: [Budget]
    let currencyCode: String
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var budgetAmount = ""

    var body: some View {
        Form {
            Section {
                TextField("Monthly budget", text: $budgetAmount)
                    .keyboardType(.decimalPad)
            } header: {
                Text("Monthly Budget (\(currencyCode))")
            }

            Section {
                Button("Save") {
                    guard let amount = Decimal(string: budgetAmount), amount > 0 else { return }
                    if let budget = budgets.first {
                        budget.totalAmount = amount
                    } else {
                        let budget = Budget(totalAmount: amount)
                        modelContext.insert(budget)
                    }
                    dismiss()
                }
                .disabled(Decimal(string: budgetAmount) ?? 0 <= 0)
            }
        }
        .navigationTitle("Edit Budget")
        .onAppear {
            if let budget = budgets.first {
                budgetAmount = String(describing: budget.totalAmount)
            }
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let purchaseManager: PurchaseManager
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Budge Pro")
                        .font(.largeTitle.bold())

                    Text("Unlock the full potential of your budget")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    proFeaturesList

                    if let monthly = purchaseManager.monthlyProduct,
                       let yearly = purchaseManager.yearlyProduct {
                        HStack(spacing: 16) {
                            subscriptionCard(
                                title: "Monthly",
                                price: monthly.displayPrice,
                                subtitle: "per month",
                                productId: monthly.id
                            )

                            subscriptionCard(
                                title: "Yearly",
                                price: yearly.displayPrice,
                                subtitle: "per year (save 58%)",
                                productId: yearly.id,
                                isRecommended: true
                            )
                        }
                        .padding(.horizontal)
                    }

                    Button("Restore Purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var proFeaturesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Custom categories", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color("BudgetGreen"))
            Label("Category budget limits", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color("BudgetGreen"))
            Label("AI deep insights", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color("BudgetGreen"))
            Label("Siri Shortcuts", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color("BudgetGreen"))
            Label("Advanced widgets", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color("BudgetGreen"))
            Label("Biometric lock", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color("BudgetGreen"))
        }
        .font(.subheadline)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func subscriptionCard(title: String, price: String, subtitle: String, productId: String, isRecommended: Bool = false) -> some View {
        Button(action: { purchaseProduct(id: productId) }) {
            VStack(spacing: 8) {
                if isRecommended {
                    Text("Best Value")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("BudgetGreen"))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Text(title)
                    .font(.headline)
                Text(price)
                    .font(.title.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isRecommended ? Color("BudgetGreen").opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isRecommended ? Color("BudgetGreen") : Color.gray.opacity(0.3), lineWidth: isRecommended ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }

    private func purchaseProduct(id: String) {
        guard let product = purchaseManager.products.first(where: { $0.id == id }) else { return }
        isPurchasing = true
        Task {
            _ = await purchaseManager.purchase(product)
            isPurchasing = false
            if purchaseManager.isPro {
                dismiss()
            }
        }
    }
}

struct CSVExportItem: Identifiable {
    let id = UUID()
    let url: URL
}
