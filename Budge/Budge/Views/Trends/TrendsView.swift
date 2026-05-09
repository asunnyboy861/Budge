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
                VStack(spacing: 16) {
                    spendingTrendChart
                    insightsSection
                    categoryBreakdown
                }
                .padding()
            }
            .navigationTitle("Trends")
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

    private var spendingTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("90-Day Spending Trend")
                .font(.headline)

            if let trendData = viewModel.trendData, !trendData.dailySpending.isEmpty {
                ChartView(data: trendData.dailySpending, movingAverage: trendData.movingAverage, currencyCode: viewModel.currencyCode)
                    .frame(height: 200)
            } else {
                Text("Add some expenses to see trends")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insights")
                .font(.headline)

            if let trendData = viewModel.trendData {
                ForEach(trendData.insights) { insight in
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
                    .padding(.vertical, 4)
                }
            } else {
                Text("Insights will appear after a few days of tracking")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category Breakdown")
                .font(.headline)

            if let trendData = viewModel.trendData, !trendData.categoryTrends.isEmpty {
                let totalSpent = trendData.categoryTrends.reduce(Decimal(0)) { $0 + $1.currentMonth }

                ForEach(trendData.categoryTrends) { trend in
                    let percentage = totalSpent > 0 ? Double(truncating: (trend.currentMonth / totalSpent * 100) as NSNumber) : 0

                    HStack {
                        Text(trend.categoryIcon)
                            .font(.title2)
                        Text(trend.categoryName)
                            .font(.subheadline)
                        Spacer()
                        Text("\(CurrencyFormatter.format(trend.currentMonth, currencyCode: viewModel.currencyCode)) (\(Int(percentage))%)")
                            .font(.subheadline.bold())
                    }

                    ProgressView(value: percentage, total: 100)
                        .progressViewStyle(BudgetProgressStyle(status: trend.direction == .down ? .great : trend.direction == .up ? .caution : .onTrack))
                        .scaleEffect(y: 1.5)
                }
            } else {
                Text("No category data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        HStack(alignment: .bottom, spacing: 1) {
            ForEach(data) { point in
                let barHeight = maxAmount > 0 ? CGFloat(truncating: (point.amount / maxAmount * Decimal(height * 0.8)) as NSNumber) : 0
                RoundedRectangle(cornerRadius: 1)
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
