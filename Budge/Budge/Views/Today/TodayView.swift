import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date,
           order: .reverse)
    private var allTransactions: [Transaction]
    @Query private var budgets: [Budget]
    @Query private var settings: [AppSetting]

    @State private var viewModel = TodayViewModel()
    @State private var showingAddTransaction = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    budgetProgressCard
                    insightCards
                    recentTransactionsList
                }
                .padding()
            }
            .navigationTitle("Budge")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color("BudgetGreen"))
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .onAppear {
                let expenses = allTransactions.filter { $0.type == .expense }
                viewModel.load(expenses: expenses, budgets: budgets, settings: settings)
            }
            .onChange(of: allTransactions.count) {
                let expenses = allTransactions.filter { $0.type == .expense }
                viewModel.load(expenses: expenses, budgets: budgets, settings: settings)
            }
        }
    }

    private var budgetProgressCard: some View {
        VStack(spacing: 12) {
            if let progress = viewModel.budgetProgress {
                Text("This Month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(CurrencyFormatter.format(progress.spent, currencyCode: viewModel.currencyCode)) / \(CurrencyFormatter.format(progress.budget, currencyCode: viewModel.currencyCode))")
                    .font(.title.bold())

                ProgressView(value: min(progress.percentage, 100), total: 100)
                    .progressViewStyle(BudgetProgressStyle(status: progress.status))
                    .scaleEffect(y: 2)

                Text("\(Int(progress.percentage))%")
                    .font(.headline)
                    .foregroundStyle(Color(progress.status.colorName))

                EncouragementText(text: progress.encouragementText, status: progress.status)
            } else {
                Text("Set a monthly budget to get started")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var insightCards: some View {
        Group {
            ForEach(Array(viewModel.insights.prefix(3).enumerated()), id: \.offset) { _, insight in
                HStack {
                    Text(insight.emoji)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(insight.text)
                            .font(.subheadline)
                        if let action = insight.actionSuggestion {
                            Text(action)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var recentTransactionsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent")
                .font(.headline)

            if viewModel.recentTransactions.isEmpty {
                Text("No expenses yet. Tap + to add one!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }

            ForEach(viewModel.recentTransactions) { transaction in
                HStack {
                    Text(transaction.categoryIcon)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(transaction.categoryName)
                            .font(.subheadline.bold())
                        if !transaction.note.isEmpty {
                            Text(transaction.note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text("-\(CurrencyFormatter.format(transaction.amount, currencyCode: viewModel.currencyCode))")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("BudgetOrange"))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
