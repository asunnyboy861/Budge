import SwiftUI

struct CalculatorButton: View {
    let title: String
    var style: ButtonStyle = .primary
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
    }
    
    var body: some View {
        Button(action: action) {
            Text(displayTitle)
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var displayTitle: String {
        switch title {
        case "delete": return "⌫"
        case "Clear": return "Clear"
        default: return title
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color("BudgetGreen").opacity(0.1)
        case .secondary:
            return Color.gray.opacity(0.1)
        case .destructive:
            return Color("BudgetOrange").opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return Color("BudgetGreen")
        case .secondary:
            return .primary
        case .destructive:
            return Color("BudgetOrange")
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        CalculatorButton(title: "1", action: {})
        CalculatorButton(title: "delete", style: .destructive, action: {})
        CalculatorButton(title: "Clear", style: .secondary, action: {})
    }
    .padding()
}
