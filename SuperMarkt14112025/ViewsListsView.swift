//
//  ListsView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

struct ListsView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var showingNewList = false
    @State private var newListName = ""
    @State private var showArchived = false
    @State private var showingDeleteConfirmation = false
    @State private var listToDelete: ShoppingList?
    
    private var activeLists: [ShoppingList] {
        viewModel.lists.filter { !$0.isArchived }
    }
    
    private var archivedLists: [ShoppingList] {
        viewModel.lists.filter { $0.isArchived }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Header Stats
                Section {
                    headerStats
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                // Active Lists
                if !activeLists.isEmpty {
                    Section {
                        ForEach(activeLists) { list in
                            NavigationLink(destination: ShoppingListDetailView(viewModel: viewModel, list: list)) {
                                ListCardCompact(list: list)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    listToDelete = list
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("حذف", systemImage: "trash.fill")
                                }
                                
                                Button {
                                    withAnimation {
                                        viewModel.archiveList(list)
                                    }
                                } label: {
                                    Label("أرشفة", systemImage: "archivebox.fill")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    withAnimation {
                                        viewModel.duplicateList(list)
                                    }
                                } label: {
                                    Label("نسخ", systemImage: "doc.on.doc.fill")
                                }
                                .tint(.blue)
                            }
                        }
                    } header: {
                        Text("القوائم النشطة")
                    }
                }
                
                // Archived Lists
                if !archivedLists.isEmpty {
                    Section {
                        Button {
                            withAnimation {
                                showArchived.toggle()
                            }
                        } label: {
                            HStack {
                                Text("القوائم المؤرشفة")
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Text("\(archivedLists.count)")
                                    .foregroundStyle(.secondary)
                                
                                Image(systemName: showArchived ? "chevron.up" : "chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if showArchived {
                            ForEach(archivedLists) { list in
                                NavigationLink(destination: ShoppingListDetailView(viewModel: viewModel, list: list)) {
                                    ListCardCompact(list: list)
                                        .opacity(0.7)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        listToDelete = list
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("حذف", systemImage: "trash.fill")
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.archiveList(list)
                                        }
                                    } label: {
                                        Label("استعادة", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
                }
                
                // Empty State
                if activeLists.isEmpty && archivedLists.isEmpty {
                    Section {
                        emptyState
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("قوائم التسوق")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewList = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .alert("قائمة جديدة", isPresented: $showingNewList) {
                TextField("اسم القائمة", text: $newListName)
                
                Button("إلغاء", role: .cancel) {
                    newListName = ""
                }
                
                Button("إنشاء") {
                    if !newListName.isEmpty {
                        viewModel.createNewList(name: newListName)
                        newListName = ""
                    }
                }
            } message: {
                Text("أدخل اسم القائمة الجديدة")
            }
            .confirmationDialog("هل أنت متأكد من حذف هذه القائمة؟", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("حذف نهائياً", role: .destructive) {
                    if let list = listToDelete {
                        withAnimation {
                            viewModel.deleteList(list)
                        }
                        listToDelete = nil
                    }
                }
                
                Button("إلغاء", role: .cancel) {
                    listToDelete = nil
                }
            } message: {
                if let list = listToDelete {
                    Text("سيتم حذف \"\(list.name)\" وجميع عناصرها نهائياً")
                }
            }
        }
    }
    
    // MARK: - Header Stats
    
    private var headerStats: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("\(activeLists.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("قوائم نشطة")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(spacing: 8) {
                    let totalItems = activeLists.reduce(0) { $0 + $1.totalItems }
                    Text("\(totalItems)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("منتج")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            VStack(spacing: 8) {
                let totalCost = activeLists.reduce(0.0) { $0 + $1.totalCost }
                Text("\(totalCost, specifier: "%.2f") ريال")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                Text("إجمالي التكلفة")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("لا توجد قوائم")
                .font(.title2.bold())
            
            Text("ابدأ بإنشاء قائمة تسوق جديدة")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingNewList = true
            } label: {
                Label("إنشاء قائمة", systemImage: "plus.circle.fill")
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
    }
}

// MARK: - List Card

struct ListCard: View {
    let list: ShoppingList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.name)
                        .font(.title3.bold())
                    
                    Text(list.createdDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if list.isArchived {
                    Image(systemName: "archivebox.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(list.purchasedItems) من \(list.totalItems)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(list.progress * 100))%")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.secondary)
                
                ProgressView(value: list.progress)
                    .tint(.green)
            }
            
            Divider()
            
            // Cost Summary
            HStack {
                Label("\(list.totalCost, specifier: "%.2f") ريال", systemImage: "banknote.fill")
                    .font(.subheadline)
                
                Spacer()
                
                Label("\(list.remainingCost, specifier: "%.2f") متبقي", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - List Card Compact (for List view)

struct ListCardCompact: View {
    let list: ShoppingList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.name)
                        .font(.headline)
                    
                    Text(list.createdDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if list.isArchived {
                    Image(systemName: "archivebox.fill")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            
            // Progress
            HStack {
                Text("\(list.purchasedItems) من \(list.totalItems)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(list.progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: list.progress)
                .tint(.green)
            
            // Cost Summary
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "banknote.fill")
                        .font(.caption)
                    Text("\(list.totalCost, specifier: "%.2f") ريال")
                        .font(.caption)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(list.remainingCost, specifier: "%.2f") متبقي")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ListsView()
}
