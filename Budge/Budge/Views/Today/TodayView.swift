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
                VStack(alignment: .leading, spacing: 24) {
                    pageHeader
                    budgetProgressCard
                    quickActions
                    insightCards
                    recentTransactionsList
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budge")
            .navigationBarTitleDisplayMode(.large)
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

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today")
                .font(.largeTitle.bold())
            Text(viewModel.currentDateFormatted)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var budgetProgressCard: some View {
        VStack(spacing: 20) {
            if let progress = viewModel.budgetProgress {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(CurrencyFormatter.format(progress.spent, currencyCode: viewModel.currencyCode))")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(progress.status.colorName))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Budget")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(CurrencyFormatter.format(progress.budget, currencyCode: viewModel.currencyCode))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray5))
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(progress.status.colorName))
                                .frame(width: min(CGFloat(progress.percentage) / 100 * geometry.size.width, geometry.size.width), height: 12)
                        }
                    }
                    .frame(height: 12)

                    HStack {
                        Text("\(Int(progress.percentage))% used")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(progress.encouragementText)
                            .font(.caption)
                            .foregroundStyle(Color(progress.status.colorName))
                            .lineLimit(1)
                    }
                }
            } else {
                emptyBudgetView
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var emptyBudgetView: some View {
        VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color("BudgetGreen").opacity(0.3))
            Text("Set a monthly budget to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                title: "Add Expense",
                icon: "plus.circle.fill",
                color: Color("BudgetGreen")
            ) {
                showingAddTransaction = true
            }

            QuickActionButton(
                title: "View Trends",
                icon: "chart.line.uptrend.xyaxis",
                color: Color("BudgetOrange")
            ) {
                // Navigate to trends - handled by tab bar
            }
        }
    }

    private var insightCards: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights")
                        .font(.headline)
                    Text("Smart tips for your budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if viewModel.insights.isEmpty {
                emptyInsightsView
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.insights.prefix(3).enumerated()), id: \.offset) { _, insight in
                        InsightRow(insight: insight)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var emptyInsightsView: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.title2)
                .foregroundStyle(Color("BudgetGreen").opacity(0.5))
            Text("Add expenses to see insights")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var recentTransactionsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Transactions")
                        .font(.headline)
                    Text("Your latest spending")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if viewModel.recentTransactions.isEmpty {
                emptyTransactionsView
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentTransactions.prefix(5).enumerated()), id: \.offset) { index, transaction in
                        TransactionRow(transaction: transaction, currencyCode: viewModel.currencyCode)
                        if index < min(viewModel.recentTransactions.count, 5) - 1 {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundStyle(Color("BudgetGreen").opacity(0.3))
            Text("No expenses yet. Tap + to add one!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct InsightRow: View {
    let insight: TrendData.TrendInsight

    var body: some View {
        HStack(spacing: 12) {
            Text(insight.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color("BudgetGreen").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.text)
                    .font(.subheadline)
                    .lineLimit(2)
                if let action = insight.actionSuggestion {
                    Text(action)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            Text(transaction.categoryIcon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color("BudgetGreen").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName)
                    .font(.subheadline.bold())
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("-\(CurrencyFormatter.format(transaction.amount, currencyCode: currencyCode))")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BudgetOrange"))
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
