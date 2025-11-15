//
//  ShoppingItem.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import Foundation
import SwiftUI

struct ShoppingItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var quantity: Int
    var price: Double
    var category: Category
    var isPurchased: Bool = false
    var notes: String = ""
    var addedDate: Date = Date()
    
    enum Category: String, Codable, CaseIterable {
        case fruits = "فواكه"
        case vegetables = "خضروات"
        case dairy = "ألبان"
        case meat = "لحوم"
        case bakery = "مخبوزات"
        case beverages = "مشروبات"
        case snacks = "وجبات خفيفة"
        case frozen = "مجمدات"
        case cleaning = "منظفات"
        case other = "أخرى"
        
        var icon: String {
            switch self {
            case .fruits: return "🍎"
            case .vegetables: return "🥬"
            case .dairy: return "🥛"
            case .meat: return "🥩"
            case .bakery: return "🍞"
            case .beverages: return "🥤"
            case .snacks: return "🍿"
            case .frozen: return "🧊"
            case .cleaning: return "🧹"
            case .other: return "📦"
            }
        }
        
        var color: Color {
            switch self {
            case .fruits: return .red
            case .vegetables: return .green
            case .dairy: return .blue
            case .meat: return .pink
            case .bakery: return .orange
            case .beverages: return .purple
            case .snacks: return .yellow
            case .frozen: return .cyan
            case .cleaning: return .mint
            case .other: return .gray
            }
        }
    }
    
    var totalPrice: Double {
        return price * Double(quantity)
    }
}
