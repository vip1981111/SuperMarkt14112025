//
//  ShoppingListWidget.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//
//  ملاحظة: هذا الملف يحتاج إلى Target منفصل للـ Widget Extension
//  للاستخدام، قم بإنشاء Widget Extension جديد في Xcode

import SwiftUI
import WidgetKit

// MARK: - Widget Entry

struct ShoppingListEntry: TimelineEntry {
    let date: Date
    let list: ShoppingList?
}

// MARK: - Widget Timeline Provider

struct ShoppingListProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShoppingListEntry {
        ShoppingListEntry(
            date: Date(),
            list: ShoppingList(
                name: "قائمة التسوق",
                items: [
                    ShoppingItem(name: "تفاح", quantity: 2, price: 10.0, category: .fruits),
                    ShoppingItem(name: "حليب", quantity: 1, price: 15.0, category: .dairy)
                ]
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ShoppingListEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingListEntry>) -> Void) {
        // Load current list from UserDefaults
        let currentList = loadCurrentList()
        let entry = ShoppingListEntry(date: Date(), list: currentList)
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadCurrentList() -> ShoppingList? {
        if let data = UserDefaults.standard.data(forKey: "SavedShoppingLists"),
           let lists = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            return lists.first(where: { !$0.isArchived })
        }
        return nil
    }
}

// MARK: - Widget View

struct ShoppingListWidgetView: View {
    let entry: ShoppingListEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let list = entry.list {
            switch family {
            case .systemSmall:
                SmallWidgetView(list: list)
            case .systemMedium:
                MediumWidgetView(list: list)
            case .systemLarge:
                LargeWidgetView(list: list)
            default:
                SmallWidgetView(list: list)
            }
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let list: ShoppingList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("\(list.purchasedItems)/\(list.totalItems)")
                    .font(.caption.bold())
            }
            
            // List Name
            Text(list.name)
                .font(.headline)
                .lineLimit(2)
            
            Spacer()
            
            // Progress
            ProgressView(value: list.progress)
                .tint(.green)
            
            // Stats
            HStack {
                Text("\(Int(list.progress * 100))%")
                    .font(.caption2)
                
                Spacer()
                
                Text("\(list.remainingCost, specifier: "%.0f") ريال")
                    .font(.caption2.bold())
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let list: ShoppingList
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Side - Stats
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cart.fill")
                        .foregroundStyle(.blue)
                    Text(list.name)
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("الإجمالي:")
                        Spacer()
                        Text("\(list.totalCost, specifier: "%.2f") ريال")
                            .bold()
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("المتبقي:")
                        Spacer()
                        Text("\(list.remainingCost, specifier: "%.2f") ريال")
                            .bold()
                    }
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
                
                ProgressView(value: list.progress)
                    .tint(.green)
                
                Text("\(list.purchasedItems) من \(list.totalItems)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Right Side - Items
            VStack(alignment: .leading, spacing: 6) {
                Text("المنتجات")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                ForEach(list.items.prefix(4)) { item in
                    HStack(spacing: 6) {
                        Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                            .foregroundStyle(item.isPurchased ? .green : .gray)
                        
                        Text(item.name)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
                
                if list.items.count > 4 {
                    Text("+\(list.items.count - 4) أخرى")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let list: ShoppingList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.name)
                        .font(.headline)
                    
                    Text("\(list.purchasedItems) من \(list.totalItems)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Progress
            ProgressView(value: list.progress)
                .tint(.green)
            
            // Cost Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("الإجمالي")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(list.totalCost, specifier: "%.2f")")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("المتبقي")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(list.remainingCost, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }
            
            Divider()
            
            // Items List
            VStack(alignment: .leading, spacing: 8) {
                Text("المنتجات")
                    .font(.subheadline.bold())
                
                ForEach(list.items.prefix(6)) { item in
                    HStack {
                        Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isPurchased ? .green : .gray)
                        
                        Text(item.name)
                            .font(.subheadline)
                            .strikethrough(item.isPurchased)
                        
                        Spacer()
                        
                        Text("\(item.totalPrice, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if list.items.count > 6 {
                    Text("+\(list.items.count - 6) منتج آخر")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Empty Widget

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("لا توجد قوائم")
                .font(.headline)
            
            Text("افتح التطبيق لإنشاء قائمة")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Widget Configuration

// ملاحظة: @main تم حذفه لأن Widget يحتاج Target منفصل
// لاستخدام Widget، أنشئ Widget Extension في Xcode
struct ShoppingListWidget: Widget {
    let kind: String = "ShoppingListWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShoppingListProvider()) { entry in
            ShoppingListWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("قائمة التسوق")
        .description("تابع تقدم قائمة التسوق الخاصة بك")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ShoppingListWidget()
} timeline: {
    ShoppingListEntry(
        date: Date(),
        list: ShoppingList(
            name: "قائمة التسوق",
            items: [
                ShoppingItem(name: "تفاح", quantity: 2, price: 10.0, category: .fruits, isPurchased: true),
                ShoppingItem(name: "حليب", quantity: 1, price: 15.0, category: .dairy),
                ShoppingItem(name: "خبز", quantity: 3, price: 5.0, category: .bakery)
            ]
        )
    )
}

#Preview(as: .systemMedium) {
    ShoppingListWidget()
} timeline: {
    ShoppingListEntry(
        date: Date(),
        list: ShoppingList(
            name: "قائمة التسوق الأسبوعية",
            items: [
                ShoppingItem(name: "تفاح", quantity: 2, price: 10.0, category: .fruits, isPurchased: true),
                ShoppingItem(name: "حليب", quantity: 1, price: 15.0, category: .dairy),
                ShoppingItem(name: "خبز", quantity: 3, price: 5.0, category: .bakery),
                ShoppingItem(name: "دجاج", quantity: 1, price: 30.0, category: .meat)
            ]
        )
    )
}
