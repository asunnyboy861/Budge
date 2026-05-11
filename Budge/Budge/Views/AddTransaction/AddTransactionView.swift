import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSetting]
    @Query private var customCategories: [CustomCategory]
    @State private var viewModel = AddTransactionViewModel()
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var showSavedConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                typeToggle
                CalculatorDisplay(
                    amountText: viewModel.amountText,
                    currencyCode: viewModel.currencyCode,
                    transactionType: viewModel.selectedType
                )
                categoryGrid
                noteField
                Spacer()
                CalculatorKeyboard(
                    amountText: $viewModel.amountText,
                    currencyCode: viewModel.currencyCode
                )
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
            .onAppear {
                viewModel.currencyCode = settings.first?.currencyCode ?? "USD"
                viewModel.customCategories = customCategories
                viewModel.isPro = purchaseManager.isPro
            }
            .onChange(of: purchaseManager.isPro) {
                viewModel.isPro = purchaseManager.isPro
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
}
