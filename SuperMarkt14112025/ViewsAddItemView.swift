//
//  AddItemView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    let list: ShoppingList
    let itemToEdit: ShoppingItem?
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var price = ""
    @State private var selectedCategory: ShoppingItem.Category = .other
    @State private var notes = ""
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, price, notes
    }
    
    init(viewModel: ShoppingListViewModel, list: ShoppingList, itemToEdit: ShoppingItem? = nil) {
        self.viewModel = viewModel
        self.list = list
        self.itemToEdit = itemToEdit
        
        if let item = itemToEdit {
            _name = State(initialValue: item.name)
            _quantity = State(initialValue: item.quantity)
            _price = State(initialValue: String(format: "%.2f", item.price))
            _selectedCategory = State(initialValue: item.category)
            _notes = State(initialValue: item.notes)
        }
    }
    
    var isValid: Bool {
        !name.isEmpty && !price.isEmpty && Double(price) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info
                Section("معلومات أساسية") {
                    TextField("اسم المنتج", text: $name)
                        .focused($focusedField, equals: .name)
                    
                    Stepper(value: $quantity, in: 1...999) {
                        HStack {
                            Text("الكمية")
                            Spacer()
                            Text("\(quantity)")
                                .font(.title3.bold())
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    HStack {
                        TextField("السعر", text: $price)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                        
                        Text("ريال")
                            .foregroundStyle(.secondary)
                    }
                    
                    if let priceValue = Double(price) {
                        HStack {
                            Text("الإجمالي")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(priceValue * Double(quantity), specifier: "%.2f") ريال")
                                .font(.headline)
                        }
                    }
                }
                
                // Category
                Section("الفئة") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(ShoppingItem.Category.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                VStack(spacing: 8) {
                                    Text(category.icon)
                                        .font(.largeTitle)
                                    
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedCategory == category ? category.color.opacity(0.2) : Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedCategory == category ? category.color : .clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Notes
                Section("ملاحظات (اختياري)") {
                    TextField("أضف ملاحظات", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle(itemToEdit == nil ? "إضافة منتج" : "تعديل منتج")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(itemToEdit == nil ? "إضافة" : "حفظ") {
                        saveItem()
                    }
                    .bold()
                    .disabled(!isValid)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("تم") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                if itemToEdit == nil {
                    focusedField = .name
                }
            }
        }
    }
    
    private func saveItem() {
        guard let priceValue = Double(price) else { return }
        
        if let itemToEdit = itemToEdit {
            var updatedItem = itemToEdit
            updatedItem.name = name
            updatedItem.quantity = quantity
            updatedItem.price = priceValue
            updatedItem.category = selectedCategory
            updatedItem.notes = notes
            
            viewModel.updateItem(in: list, item: updatedItem)
        } else {
            let newItem = ShoppingItem(
                name: name,
                quantity: quantity,
                price: priceValue,
                category: selectedCategory,
                notes: notes
            )
            
            viewModel.addItem(to: list, item: newItem)
        }
        
        dismiss()
    }
}
