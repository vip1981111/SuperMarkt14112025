//
//  ShoppingListViewModel.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var lists: [ShoppingList] = []
    @Published var currentList: ShoppingList?
    @Published var searchText: String = ""
    @Published var selectedCategory: ShoppingItem.Category?
    
    private let saveKey = "SavedShoppingLists"
    
    init() {
        loadLists()
        if lists.isEmpty {
            createSampleList()
        }
    }
    
    // MARK: - List Management
    
    func createNewList(name: String) {
        let newList = ShoppingList(name: name, items: [])
        lists.insert(newList, at: 0)
        currentList = newList
        saveLists()
    }
    
    func deleteList(_ list: ShoppingList) {
        lists.removeAll { $0.id == list.id }
        if currentList?.id == list.id {
            currentList = lists.first
        }
        saveLists()
    }
    
    func archiveList(_ list: ShoppingList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index].isArchived.toggle()
            saveLists()
        }
    }
    
    func duplicateList(_ list: ShoppingList) {
        var newList = list
        newList.id = UUID()
        newList.name = "\(list.name) (نسخة)"
        newList.createdDate = Date()
        newList.isArchived = false
        newList.items = list.items.map { item in
            var newItem = item
            newItem.id = UUID()
            newItem.isPurchased = false
            return newItem
        }
        lists.insert(newList, at: 0)
        saveLists()
    }
    
    // MARK: - Item Management
    
    func addItem(to list: ShoppingList, item: ShoppingItem) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index].items.append(item)
            saveLists()
        }
    }
    
    func updateItem(in list: ShoppingList, item: ShoppingItem) {
        if let listIndex = lists.firstIndex(where: { $0.id == list.id }),
           let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) {
            lists[listIndex].items[itemIndex] = item
            saveLists()
        }
    }
    
    func deleteItem(from list: ShoppingList, item: ShoppingItem) {
        if let listIndex = lists.firstIndex(where: { $0.id == list.id }) {
            lists[listIndex].items.removeAll { $0.id == item.id }
            saveLists()
        }
    }
    
    func togglePurchased(in list: ShoppingList, item: ShoppingItem) {
        if let listIndex = lists.firstIndex(where: { $0.id == list.id }),
           let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) {
            lists[listIndex].items[itemIndex].isPurchased.toggle()
            saveLists()
        }
    }
    
    func clearPurchasedItems(from list: ShoppingList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index].items.removeAll { $0.isPurchased }
            saveLists()
        }
    }
    
    // MARK: - Filtering
    
    func filteredItems(from list: ShoppingList) -> [ShoppingItem] {
        var items = list.items
        
        // Filter by search text
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filter by category
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        return items.sorted { !$0.isPurchased && $1.isPurchased }
    }
    
    // MARK: - Statistics
    
    func totalSpentThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        return lists.flatMap { $0.items }
            .filter { item in
                item.isPurchased &&
                calendar.isDate(item.addedDate, equalTo: now, toGranularity: .month)
            }
            .reduce(0) { $0 + $1.totalPrice }
    }
    
    func mostPurchasedCategory() -> ShoppingItem.Category? {
        let purchasedItems = lists.flatMap { $0.items }.filter { $0.isPurchased }
        let grouped = Dictionary(grouping: purchasedItems, by: { $0.category })
        return grouped.max(by: { $0.value.count < $1.value.count })?.key
    }
    
    // MARK: - Persistence
    
    private func saveLists() {
        if let encoded = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            lists = decoded
            currentList = lists.first
        }
    }
    
    // MARK: - Sample Data
    
    private func createSampleList() {
        let sampleItems = [
            ShoppingItem(name: "تفاح", quantity: 2, price: 10.0, category: .fruits),
            ShoppingItem(name: "حليب", quantity: 1, price: 15.0, category: .dairy),
            ShoppingItem(name: "خبز", quantity: 3, price: 5.0, category: .bakery),
            ShoppingItem(name: "طماطم", quantity: 1, price: 8.0, category: .vegetables)
        ]
        
        let sampleList = ShoppingList(name: "قائمة التسوق الأسبوعية", items: sampleItems)
        lists.append(sampleList)
        currentList = sampleList
        saveLists()
    }
}
