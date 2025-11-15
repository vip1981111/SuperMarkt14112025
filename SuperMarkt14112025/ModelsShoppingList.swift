//
//  ShoppingList.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import Foundation

struct ShoppingList: Identifiable, Codable {
    var id = UUID()
    var name: String
    var items: [ShoppingItem]
    var createdDate: Date = Date()
    var isArchived: Bool = false
    
    var totalItems: Int {
        return items.count
    }
    
    var purchasedItems: Int {
        return items.filter { $0.isPurchased }.count
    }
    
    var totalCost: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var purchasedCost: Double {
        return items.filter { $0.isPurchased }.reduce(0) { $0 + $1.totalPrice }
    }
    
    var remainingCost: Double {
        return totalCost - purchasedCost
    }
    
    var progress: Double {
        guard totalItems > 0 else { return 0 }
        return Double(purchasedItems) / Double(totalItems)
    }
}
