import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddTransactionViewModel()
    @State private var showSavedConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                typeToggle
                amountDisplay
                categoryGrid
                noteField
                saveButton
            }
            .padding()
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Saved!", isPresented: $showSavedConfirmation) {
                Button("Add Another") { viewModel.reset() }
                Button("Done") { dismiss() }
            } message: {
                if let progress = viewModel.selectedCategory {
                    Text("\(progress.name) recorded successfully")
                }
            }
        }
    }

    private var typeToggle: some View {
        Picker("Type", selection: $viewModel.selectedType) {
            Text("Expense").tag(Transaction.TransactionType.expense)
            Text("Income").tag(Transaction.TransactionType.income)
        }
        .pickerStyle(.segmented)
    }

    private var amountDisplay: some View {
        Text(formatAmount(viewModel.amountText))
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundStyle(viewModel.selectedType == .expense ? Color("BudgetOrange") : Color("BudgetGreen"))
    }

    private var categoryGrid: some View {
        let categories = viewModel.currentCategories

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(categories) { category in
                CategoryButton(
                    category: category,
                    isSelected: viewModel.selectedCategory?.id == category.id
                ) {
                    viewModel.selectedCategory = category
                }
            }
        }
    }

    private var noteField: some View {
        TextField("Note (optional)", text: $viewModel.note)
            .textFieldStyle(.roundedBorder)
    }

    private var saveButton: some View {
        Button(action: saveTransaction) {
            Text("Save")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canSave ? Color("BudgetGreen") : Color.gray.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.canSave)
    }

    private func saveTransaction() {
        if viewModel.save(context: modelContext) != nil {
            showSavedConfirmation = true
        }
    }

    private func formatAmount(_ text: String) -> String {
        let value = Decimal(string: text) ?? 0
        return CurrencyFormatter.format(value)
    }
}
