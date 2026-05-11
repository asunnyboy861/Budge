import SwiftUI

struct CalculatorDisplay: View {
    let amountText: String
    let currencyCode: String
    let transactionType: Transaction.TransactionType
    
    var body: some View {
        VStack(spacing: 8) {
            Text(formattedAmount)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(amountColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var formattedAmount: String {
        guard let amount = Decimal(string: amountText) else {
            return CurrencyFormatter.format(0, currencyCode: currencyCode)
        }
        return CurrencyFormatter.format(amount, currencyCode: currencyCode)
    }
    
    private var amountColor: Color {
        transactionType == .expense ? Color("BudgetOrange") : Color("BudgetGreen")
    }
}

#Preview {
    VStack {
        CalculatorDisplay(
            amountText: "123.45",
            currencyCode: "USD",
            transactionType: .expense
        )
        CalculatorDisplay(
            amountText: "5000",
            currencyCode: "USD",
            transactionType: .income
        )
    }
}
