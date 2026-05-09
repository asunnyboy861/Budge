import SwiftUI

struct EncouragementText: View {
    let text: String
    let status: BudgetProgress.BudgetStatus

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}
