import SwiftUI

struct BudgetProgressStyle: ProgressViewStyle {
    let status: BudgetProgress.BudgetStatus

    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(status.colorName))
                    .frame(width: geometry.size.width * CGFloat(progress), height: 8)
            }
        }
        .frame(height: 8)
    }
}
