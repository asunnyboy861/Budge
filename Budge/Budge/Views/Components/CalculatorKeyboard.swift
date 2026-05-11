import SwiftUI

struct CalculatorKeyboard: View {
    @Binding var amountText: String
    let currencyCode: String
    let maxValue: Decimal = 999_999.99
    
    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "delete"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        CalculatorButton(
                            title: button,
                            style: buttonStyle(for: button),
                            action: { handleButtonTap(button) }
                        )
                    }
                }
            }
            
            HStack(spacing: 12) {
                CalculatorButton(
                    title: "Clear",
                    style: .secondary,
                    action: { amountText = "0" }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
    
    private func buttonStyle(for button: String) -> CalculatorButton.ButtonStyle {
        switch button {
        case "delete":
            return .destructive
        default:
            return .primary
        }
    }
    
    private func handleButtonTap(_ button: String) {
        switch button {
        case "delete":
            deleteLastDigit()
        case ".":
            addDecimalPoint()
        default:
            appendDigit(button)
        }
    }
    
    private func appendDigit(_ digit: String) {
        if amountText == "0" {
            amountText = digit
        } else {
            let newAmount = amountText + digit
            if isValidAmount(newAmount) {
                amountText = newAmount
            }
        }
    }
    
    private func addDecimalPoint() {
        if !amountText.contains(".") {
            amountText += "."
        }
    }
    
    private func deleteLastDigit() {
        if amountText.count > 1 {
            amountText.removeLast()
        } else {
            amountText = "0"
        }
    }
    
    private func isValidAmount(_ text: String) -> Bool {
        guard let amount = Decimal(string: text) else { return false }
        
        if amount > maxValue {
            return false
        }
        
        if let decimalIndex = text.firstIndex(of: ".") {
            let decimalPart = text[text.index(after: decimalIndex)...]
            if decimalPart.count > 2 {
                return false
            }
        }
        
        return true
    }
}

#Preview {
    @Previewable @State var amount = "0"
    return CalculatorKeyboard(amountText: $amount, currencyCode: "USD")
}
