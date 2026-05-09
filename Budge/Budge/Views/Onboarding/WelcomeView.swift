import SwiftUI
import SwiftData

struct WelcomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSetting]
    @State private var selectedCurrency = "USD"
    @State private var budgetAmount = ""
    @State private var step = 0

    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY"]

    var body: some View {
        VStack(spacing: 32) {
            if step == 0 {
                currencyStep
            } else {
                budgetStep
            }
        }
        .padding(24)
    }

    private var currencyStep: some View {
        VStack(spacing: 24) {
            Text("Welcome to Budge")
                .font(.largeTitle.bold())

            Text("Choose your currency")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(currencies, id: \.self) { currency in
                    Button(action: { selectedCurrency = currency }) {
                        Text(currency)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedCurrency == currency ? Color("BudgetGreen").opacity(0.2) : Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedCurrency == currency ? Color("BudgetGreen") : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button(action: { step = 1 }) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("BudgetGreen"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var budgetStep: some View {
        VStack(spacing: 24) {
            Text("Set Monthly Budget")
                .font(.largeTitle.bold())

            Text("How much do you want to budget each month?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(CurrencyFormatter.format(0, currencyCode: selectedCurrency).prefix(1))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("BudgetGreen"))

                TextField("0", text: $budgetAmount)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("BudgetGreen"))
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal)

            Button(action: saveAndContinue) {
                Text("Start Budgeting!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canContinue ? Color("BudgetGreen") : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canContinue)
        }
    }

    private var canContinue: Bool {
        let amount = Decimal(string: budgetAmount) ?? 0
        return amount > 0
    }

    private func saveAndContinue() {
        guard let amount = Decimal(string: budgetAmount), amount > 0 else { return }

        let setting = settings.first ?? AppSetting()
        setting.currencyCode = selectedCurrency
        setting.hasCompletedOnboarding = true

        if !settings.contains(where: { $0.id == setting.id }) {
            modelContext.insert(setting)
        }

        let budget = Budget(totalAmount: amount, period: .monthly)
        modelContext.insert(budget)
    }
}
