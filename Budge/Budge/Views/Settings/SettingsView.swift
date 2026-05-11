import SwiftUI
import SwiftData
import StoreKit
import SafariServices

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSetting]
    @Query private var transactions: [Transaction]

    @State private var viewModel = SettingsViewModel()
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var showingPaywall = false
    @State private var showingContactSupport = false
    @State private var exportItem: CSVExportItem?
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

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
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.load(settings: settings, purchaseManager: purchaseManager)
            }
            .onChange(of: purchaseManager.isPro) {
                viewModel.isPro = purchaseManager.isPro
            }
        }
    }

    private var budgetSection: some View {
        Section {
            NavigationLink {
                EditBudgetView(budgets: budgetsQuery, currencyCode: viewModel.currencyCode)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("BudgetGreen"))
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly Budget")
                            .font(.subheadline.bold())
                        Text("Set your spending limit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Budget")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .textCase(nil)
        }
    }

    private var preferencesSection: some View {
        Section {
            HStack {
                Image(systemName: "globe")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Currency")
                        .font(.subheadline.bold())
                    Text("Display currency for amounts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Picker("", selection: $viewModel.currencyCode) {
                    ForEach(["USD", "EUR", "GBP", "CAD", "AUD", "JPY"], id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .labelsHidden()
                .frame(width: 80)
            }
            .padding(.vertical, 4)

            Divider()
                .padding(.leading, 44)

            NavigationLink {
                CustomCategoryView(isPro: $viewModel.isPro)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.title2)
                        .foregroundStyle(.purple)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Custom Categories")
                            .font(.subheadline.bold())
                        Text("Personalize your categories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !viewModel.isPro {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .disabled(!viewModel.isPro)

            Divider()
                .padding(.leading, 44)

            HStack {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminder")
                        .font(.subheadline.bold())
                    Text("Get notified to log expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: $viewModel.reminderEnabled)
                    .labelsHidden()
            }
            .padding(.vertical, 4)

            if viewModel.reminderEnabled {
                Divider()
                    .padding(.leading, 44)

                HStack {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundStyle(.orange)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminder Time")
                            .font(.subheadline.bold())
                        Text("When to send notification")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    DatePicker("", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(width: 120)
                }
                .padding(.vertical, 4)
            }

            Divider()
                .padding(.leading, 44)

            HStack {
                Image(systemName: "touchid")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Biometric Lock")
                        .font(.subheadline.bold())
                    Text("Require Face ID / Touch ID")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !viewModel.isPro {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Toggle("", isOn: $viewModel.biometricEnabled)
                    .labelsHidden()
                    .disabled(!viewModel.isPro)
            }
            .padding(.vertical, 4)

            Divider()
                .padding(.leading, 44)

            HStack {
                Image(systemName: "icloud")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Sync")
                        .font(.subheadline.bold())
                    Text("Sync across devices")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: $viewModel.iCloudSyncEnabled)
                    .labelsHidden()
            }
            .padding(.vertical, 4)
        } header: {
            Text("Preferences")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .textCase(nil)
        }
        .onChange(of: viewModel.currencyCode) { saveSettings() }
        .onChange(of: viewModel.reminderEnabled) { saveSettings() }
        .onChange(of: viewModel.reminderTime) { saveSettings() }
        .onChange(of: viewModel.biometricEnabled) { saveSettings() }
        .onChange(of: viewModel.iCloudSyncEnabled) { saveSettings() }
        .alert("Restart Required", isPresented: $viewModel.showiCloudRestartAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please restart the app to apply iCloud sync changes. Your data will be synced after restart.")
        }
    }

    private var proSection: some View {
        Section {
            if viewModel.isPro {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(Color("BudgetGreen"))
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Budge Pro Active")
                            .font(.subheadline.bold())
                        Text("All features unlocked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            } else {
                Button(action: { showingPaywall = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color("BudgetGreen"))
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Pro")
                                .font(.subheadline.bold())
                            Text("Unlock all features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .padding(.leading, 44)

            Button {
                Task {
                    let restored = await purchaseManager.restorePurchases()
                    if restored {
                        restoreMessage = "Purchases restored successfully!"
                    } else {
                        restoreMessage = "No previous purchases found."
                    }
                    showRestoreAlert = true
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32)
                    Text("Restore Purchases")
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } header: {
            Text("Subscription")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .textCase(nil)
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreMessage)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private var dataSection: some View {
        Section {
            Button(action: exportCSV) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Export CSV")
                            .font(.subheadline.bold())
                        Text("Download your transaction data")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.leading, 44)

            NavigationLink {
                ContactSupportView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.title2)
                        .foregroundStyle(.green)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Contact Support")
                            .font(.subheadline.bold())
                        Text("Get help with the app")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Data & Support")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .textCase(nil)
        }
    }

    private var aboutSection: some View {
        Section {
            Link(destination: Constants.privacyURL) {
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32)
                    Text("Privacy Policy")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Divider()
                .padding(.leading, 44)

            Link(destination: Constants.termsURL) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32)
                    Text("Terms of Use")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Divider()
                .padding(.leading, 44)

            Link(destination: Constants.supportURL) {
                HStack(spacing: 12) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32)
                    Text("Support")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Legal")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .textCase(nil)
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
                HStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color("BudgetGreen"))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Set your monthly spending limit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $budgetAmount)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Monthly Budget")
            } footer: {
                Text("Current currency: \(currencyCode)")
            }

            Section {
                Button {
                    guard let amount = Decimal(string: budgetAmount), amount > 0 else { return }
                    if let budget = budgets.first {
                        budget.totalAmount = amount
                    } else {
                        let budget = Budget(totalAmount: amount)
                        modelContext.insert(budget)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Budget")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(
                    Decimal(string: budgetAmount) ?? 0 <= 0
                        ? Color(.systemGray4)
                        : Color("BudgetGreen")
                )
                .cornerRadius(12)
                .disabled(Decimal(string: budgetAmount) ?? 0 <= 0)
            }
        }
        .navigationTitle("Edit Budget")
        .navigationBarTitleDisplayMode(.large)
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
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    proFeaturesList

                    if let monthly = purchaseManager.monthlyProduct,
                       let yearly = purchaseManager.yearlyProduct {
                        subscriptionOptions(monthly: monthly, yearly: yearly)
                    } else if purchaseManager.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 32))
                                .foregroundStyle(.orange)
                            Text(purchaseManager.loadError ?? "Unable to load subscription options. Please check your internet connection.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Retry") {
                                Task {
                                    await purchaseManager.loadProducts()
                                }
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("BudgetGreen"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color("BudgetGreen").opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding()
                    }

                    subscriptionTermsSection

                    legalLinksSection
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
            .onChange(of: purchaseManager.isPro) {
                if purchaseManager.isPro {
                    dismiss()
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("BudgetGreen"))
            Text("Budge Pro")
                .font(.system(size: 34, weight: .bold))
            Text("Unlock the full potential of your budget tracker")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private var proFeaturesList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(proFeatures, id: \.title) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("BudgetGreen"))
                    Text(feature.title)
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.vertical, 12)

                if feature.title != proFeatures.last?.title {
                    Divider()
                        .padding(.leading, 32)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func subscriptionOptions(monthly: Product, yearly: Product) -> some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.headline)

            VStack(spacing: 12) {
                subscriptionCard(
                    title: "Budge Pro Monthly",
                    price: monthly.displayPrice,
                    period: "1 month",
                    pricePerUnit: "\(monthly.displayPrice)/month",
                    productId: monthly.id
                )

                subscriptionCard(
                    title: "Budge Pro Yearly",
                    price: yearly.displayPrice,
                    period: "1 year",
                    pricePerUnit: "\(yearly.displayPrice)/year (\(String(format: "%.2f", NSDecimalNumber(decimal: yearly.price).doubleValue / 12))/month)",
                    productId: yearly.id,
                    isRecommended: true
                )
            }
        }
    }

    private func subscriptionCard(title: String, price: String, period: String, pricePerUnit: String, productId: String, isRecommended: Bool = false) -> some View {
        Button(action: { purchaseProduct(id: productId) }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    if isRecommended {
                        Text("Best Value")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color("BudgetGreen"))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

                    Text(title)
                        .font(.headline)
                    Text("Length: \(period)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(pricePerUnit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(price)
                    .font(.title2.bold())
                    .foregroundStyle(isRecommended ? Color("BudgetGreen") : .primary)
            }
            .padding()
            .background(isRecommended ? AnyView(LinearGradient(colors: [Color("BudgetGreen").opacity(0.15), Color("BudgetGreen").opacity(0.05)], startPoint: .leading, endPoint: .trailing)) : AnyView(Color(.tertiarySystemGroupedBackground)))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isRecommended ? Color("BudgetGreen") : Color(.systemGray4), lineWidth: isRecommended ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }

    private var subscriptionTermsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subscription Terms")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("• Payment will be charged to your Apple ID account at confirmation of purchase.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("• Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("• Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("• You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("• Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var legalLinksSection: some View {
        VStack(spacing: 12) {
            Button("Restore Purchases") {
                Task {
                    let restored = await purchaseManager.restorePurchases()
                    if restored {
                        dismiss()
                    } else {
                        errorMessage = "No previous purchases found to restore."
                        showError = true
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(Color("BudgetGreen"))

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: Constants.privacyURL)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("•")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Link("Terms of Use", destination: Constants.termsURL)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }

    private func purchaseProduct(id: String) {
        guard let product = purchaseManager.products.first(where: { $0.id == id }) else {
            errorMessage = "Product not found. Please try again later."
            showError = true
            return
        }
        isPurchasing = true
        Task {
            let success = await purchaseManager.purchase(product)
            isPurchasing = false
            if success {
                dismiss()
            } else if let error = purchaseManager.purchaseError {
                errorMessage = error
                showError = true
            }
        }
    }

    private struct ProFeature: Identifiable {
        let id = UUID()
        let title: String
    }

    private let proFeatures = [
        ProFeature(title: "Custom categories"),
        ProFeature(title: "Category budget limits"),
        ProFeature(title: "AI deep insights"),
        ProFeature(title: "Siri Shortcuts"),
        ProFeature(title: "Advanced widgets"),
        ProFeature(title: "Biometric lock")
    ]
}

struct CSVExportItem: Identifiable {
    let id = UUID()
    let url: URL
}
