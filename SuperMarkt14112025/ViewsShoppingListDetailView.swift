//
//  ShoppingListDetailView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

struct ShoppingListDetailView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    let list: ShoppingList
    
    @State private var showingAddItem = false
    @State private var showingCamera = false
    @State private var showingStats = false
    @State private var itemToEdit: ShoppingItem?
    @State private var showDeleteAlert = false
    
    private var filteredItems: [ShoppingItem] {
        viewModel.filteredItems(from: list)
    }
    
    private var unpurchasedItems: [ShoppingItem] {
        filteredItems.filter { !$0.isPurchased }
    }
    
    private var purchasedItems: [ShoppingItem] {
        filteredItems.filter { $0.isPurchased }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Stats
                    statsHeader
                    
                    // Search Bar
                    searchBar
                    
                    // Category Filter
                    categoryFilter
                    
                    // Items List
                    VStack(spacing: 16) {
                        // Unpurchased Items
                        if !unpurchasedItems.isEmpty {
                            itemsSection(title: "قائمة التسوق", items: unpurchasedItems, isPurchased: false)
                        }
                        
                        // Purchased Items
                        if !purchasedItems.isEmpty {
                            itemsSection(title: "تم الشراء", items: purchasedItems, isPurchased: true)
                        }
                        
                        if filteredItems.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            
            // Floating Action Buttons
            floatingButtons
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingStats = true
                    } label: {
                        Label("الإحصائيات", systemImage: "chart.bar.fill")
                    }
                    
                    Button {
                        showingCamera = true
                    } label: {
                        Label("تسوق بالمبلغ", systemImage: "camera.fill")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("مسح المشتريات", systemImage: "trash")
                    }
                    .disabled(purchasedItems.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(viewModel: viewModel, list: list)
        }
        .sheet(item: $itemToEdit) { item in
            AddItemView(viewModel: viewModel, list: list, itemToEdit: item)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
        .sheet(isPresented: $showingStats) {
            StatisticsView(viewModel: viewModel, list: list)
        }
        .alert("مسح المشتريات", isPresented: $showDeleteAlert) {
            Button("إلغاء", role: .cancel) { }
            Button("مسح", role: .destructive) {
                viewModel.clearPurchasedItems(from: list)
            }
        } message: {
            Text("هل تريد حذف جميع المنتجات المشتراة من القائمة؟")
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        VStack(spacing: 12) {
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("\(list.purchasedItems) من \(list.totalItems)")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(list.progress * 100))%")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView(value: list.progress)
                    .tint(.green)
            }
            
            // Cost Summary
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("الإجمالي")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(list.totalCost, specifier: "%.2f")")
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("تم الشراء")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(list.purchasedCost, specifier: "%.2f")")
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("المتبقي")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(list.remainingCost, specifier: "%.2f")")
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("بحث في المنتجات...", text: $viewModel.searchText)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button {
                    viewModel.selectedCategory = nil
                } label: {
                    Text("الكل")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedCategory == nil ? Color.blue : Color(.systemGray6))
                        .foregroundStyle(viewModel.selectedCategory == nil ? .white : .primary)
                        .clipShape(Capsule())
                }
                
                ForEach(ShoppingItem.Category.allCases, id: \.self) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        HStack(spacing: 6) {
                            Text(category.icon)
                            Text(category.rawValue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedCategory == category ? category.color : Color(.systemGray6))
                        .foregroundStyle(viewModel.selectedCategory == category ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Items Section
    
    private func itemsSection(title: String, items: [ShoppingItem], isPurchased: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ForEach(items) { item in
                ItemRow(item: item, isPurchased: isPurchased) {
                    viewModel.togglePurchased(in: list, item: item)
                } onEdit: {
                    itemToEdit = item
                } onDelete: {
                    viewModel.deleteItem(from: list, item: item)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("لا توجد منتجات")
                .font(.title2.bold())
            
            Text("ابدأ بإضافة منتجات لقائمة التسوق")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Floating Buttons
    
    private var floatingButtons: some View {
        HStack(spacing: 12) {
            // Camera Button
            Button {
                showingCamera = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("تسوق بالمبلغ")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.gradient)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .shadow(radius: 5)
            }
            
            // Add Item Button
            Button {
                showingAddItem = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .frame(width: 56, height: 56)
                    .background(.green.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: ShoppingItem
    let isPurchased: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: isPurchased ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isPurchased ? .green : .gray)
            }
            
            // Category Icon
            Text(item.category.icon)
                .font(.title2)
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(isPurchased)
                
                HStack {
                    Text("الكمية: \(item.quantity)")
                        .font(.caption)
                    
                    if !item.notes.isEmpty {
                        Text("•")
                        Text(item.notes)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(isPurchased ? .green : .primary)
                
                if item.quantity > 1 {
                    Text("\(item.price, specifier: "%.2f") × \(item.quantity)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(isPurchased ? Color.green.opacity(0.1) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isPurchased ? 0.7 : 1.0)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("تعديل", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("حذف", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShoppingListDetailView(
            viewModel: ShoppingListViewModel(),
            list: ShoppingList(name: "قائمة تجريبية", items: [
                ShoppingItem(name: "تفاح", quantity: 2, price: 10.0, category: .fruits),
                ShoppingItem(name: "حليب", quantity: 1, price: 15.0, category: .dairy, isPurchased: true)
            ])
        )
    }
}
