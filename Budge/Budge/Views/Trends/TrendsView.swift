import SwiftUI
import SwiftData

struct TrendsView: View {
    @Query(sort: \Transaction.date,
           order: .reverse)
    private var allTransactions: [Transaction]
    @Query private var settings: [AppSetting]

    @State private var viewModel = TrendsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    pageHeader
                    spendingTrendChart
                    insightsSection
                    categoryBreakdown
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trends")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                let expenses = allTransactions.filter { $0.type == .expense }
                viewModel.load(transactions: expenses, settings: settings)
            }
            .onChange(of: allTransactions.count) {
                let expenses = allTransactions.filter { $0.type == .expense }
                viewModel.load(transactions: expenses, settings: settings)
            }
        }
    }

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Spending")
                .font(.largeTitle.bold())
            Text("Track patterns and insights")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var spendingTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("90-Day Trend")
                        .font(.headline)
                    Text("Daily spending with 7-day average")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if let trendData = viewModel.trendData, !trendData.dailySpending.isEmpty {
                ChartView(data: trendData.dailySpending, movingAverage: trendData.movingAverage, currencyCode: viewModel.currencyCode)
                    .frame(height: 220)
            } else {
                emptyChartView
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(Color("BudgetGreen").opacity(0.3))
            Text("Add some expenses to see trends")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights")
                        .font(.headline)
                    Text("Smart observations from your data")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if let trendData = viewModel.trendData, !trendData.insights.isEmpty {
                VStack(spacing: 12) {
                    ForEach(trendData.insights) { insight in
                        InsightCard(insight: insight)
                    }
                }
            } else {
                emptyInsightsView
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
            Text("Insights will appear after a few days of tracking")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category Breakdown")
                        .font(.headline)
                    Text("Where your money goes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if let trendData = viewModel.trendData, !trendData.categoryTrends.isEmpty {
                let totalSpent = trendData.categoryTrends.reduce(Decimal(0)) { $0 + $1.currentMonth }

                VStack(spacing: 16) {
                    ForEach(trendData.categoryTrends) { trend in
                        let percentage = totalSpent > 0 ? Double(truncating: (trend.currentMonth / totalSpent * 100) as NSNumber) : 0
                        CategoryTrendRow(trend: trend, percentage: percentage, currencyCode: viewModel.currencyCode)
                    }
                }
            } else {
                emptyCategoryView
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var emptyCategoryView: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.title2)
                .foregroundStyle(Color("BudgetGreen").opacity(0.5))
            Text("No category data yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct InsightCard: View {
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

struct CategoryTrendRow: View {
    let trend: TrendData.CategoryTrend
    let percentage: Double
    let currencyCode: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Text(trend.categoryIcon)
                        .font(.title3)
                    Text(trend.categoryName)
                        .font(.subheadline.bold())
                }

                Spacer()

                Text("\(CurrencyFormatter.format(trend.currentMonth, currencyCode: currencyCode))")
                    .font(.subheadline.bold())
                Text("(\(Int(percentage))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: max(CGFloat(percentage) / 100 * geometry.size.width, 4), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var progressColor: Color {
        switch trend.direction {
        case .down:
            return Color("BudgetGreen")
        case .up:
            return Color("BudgetOrange")
        case .flat:
            return Color(.systemGray)
        }
    }
}

struct ChartView: View {
    let data: [TrendData.DailyPoint]
    let movingAverage: [Decimal]
    let currencyCode: String

    var body: some View {
        GeometryReader { geometry in
            let maxAmount = data.map(\.amount).max() ?? 1
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                dailyBars(width: width, height: height, maxAmount: maxAmount)
                movingAverageLine(width: width, height: height, maxAmount: maxAmount)
            }
        }
    }

    private func dailyBars(width: CGFloat, height: CGFloat, maxAmount: Decimal) -> some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(data) { point in
                let barHeight = maxAmount > 0 ? CGFloat(truncating: (point.amount / maxAmount * Decimal(height * 0.8)) as NSNumber) : 0
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("BudgetGreen").opacity(0.3))
                    .frame(height: max(barHeight, 2))
            }
        }
    }

    private func movingAverageLine(width: CGFloat, height: CGFloat, maxAmount: Decimal) -> some View {
        if movingAverage.count < 2 { return AnyView(EmptyView()) }

        let points = movingAverage.enumerated().map { index, value in
            CGPoint(
                x: CGFloat(index) / CGFloat(movingAverage.count - 1) * width,
                y: height - CGFloat(truncating: (value / max(maxAmount, 1) * Decimal(height * 0.8)) as NSNumber)
            )
        }

        return AnyView(
            Path { path in
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color("BudgetOrange"), lineWidth: 2)
        )
    }
}
