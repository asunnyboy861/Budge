import SwiftUI
import SwiftData

struct CustomCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomCategory.createdAt, order: .reverse)
    private var customCategories: [CustomCategory]
    
    @State private var showingAddSheet = false
    @State private var selectedType: Transaction.TransactionType = .expense
    @Binding var isPro: Bool
    
    var body: some View {
        List {
            Picker("Type", selection: $selectedType) {
                Text("Expense").tag(Transaction.TransactionType.expense)
                Text("Income").tag(Transaction.TransactionType.income)
            }
            .pickerStyle(.segmented)
            
            Section {
                ForEach(filteredCategories) { category in
                    HStack {
                        Text(category.icon)
                            .font(.title2)
                        Text(category.name)
                        Spacer()
                    }
                }
                .onDelete(perform: deleteCategories)
            } header: {
                Text("Custom Categories")
            }
            
            if !isPro {
                Section {
                    Text("Upgrade to Pro to add custom categories")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
                .disabled(!isPro)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCategorySheet(type: selectedType)
        }
    }
    
    private var filteredCategories: [CustomCategory] {
        customCategories.filter { $0.type == selectedType }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = filteredCategories[index]
            CategoryManager.deleteCustomCategory(category, context: modelContext)
        }
    }
}

struct AddCategorySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let type: Transaction.TransactionType
    
    @State private var name = ""
    @State private var selectedIcon = "📝"
    
    private let icons = ["📝", "🍔", "☕", "🚗", "🛒", "🏠", "💊", "🎬", "✈️", "📱", "💰", "💻", "📈", "🎁", "💼", "🎨", "📚", "🎵", "🏃", "🎮"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category name", text: $name)
                } header: {
                    Text("Name")
                }
                
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Text(icon)
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedIcon == icon ? Color("BudgetGreen").opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Icon")
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _ = CategoryManager.addCustomCategory(
                            name: name,
                            icon: selectedIcon,
                            type: type,
                            context: modelContext
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CustomCategoryView(isPro: .constant(true))
    }
}
