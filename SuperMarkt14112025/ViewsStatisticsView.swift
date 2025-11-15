//
//  StatisticsView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    let list: ShoppingList
    @Environment(\.dismiss) private var dismiss
    
    private var categoryData: [(category: ShoppingItem.Category, total: Double, count: Int)] {
        let grouped = Dictionary(grouping: list.items, by: { $0.category })
        return grouped.map { category, items in
            let total = items.reduce(0) { $0 + $1.totalPrice }
            return (category, total, items.count)
        }
        .sorted { $0.total > $1.total }
    }
    
    private var purchasedVsUnpurchased: [(status: String, count: Int, color: Color)] {
        [
            ("تم الشراء", list.purchasedItems, .green),
            ("لم يتم", list.totalItems - list.purchasedItems, .orange)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Cards
                    overviewCards
                    
                    // Category Breakdown
                    categoryBreakdown
                    
                    // Purchase Status Chart
                    purchaseStatusChart
                    
                    // Spending by Category Chart
                    spendingChart
                }
                .padding()
            }
            .navigationTitle("الإحصائيات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Overview Cards
    
    private var overviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "إجمالي المنتجات",
                    value: "\(list.totalItems)",
                    icon: "cart.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "تم الشراء",
                    value: "\(list.purchasedItems)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "إجمالي التكلفة",
                    value: String(format: "%.2f ريال", list.totalCost),
                    icon: "banknote.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "المتبقي",
                    value: String(format: "%.2f ريال", list.remainingCost),
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Category Breakdown
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("التوزيع حسب الفئات")
                .font(.title2.bold())
            
            VStack(spacing: 12) {
                ForEach(categoryData, id: \.category) { data in
                    HStack {
                        Text(data.category.icon)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.category.rawValue)
                                .font(.headline)
                            
                            Text("\(data.count) منتج")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(data.total, specifier: "%.2f") ريال")
                                .font(.headline)
                            
                            let percentage = (data.total / list.totalCost) * 100
                            Text("\(percentage, specifier: "%.1f")%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(data.category.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Purchase Status Chart
    
    private var purchaseStatusChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("حالة الشراء")
                .font(.title2.bold())
            
            Chart(purchasedVsUnpurchased, id: \.status) { data in
                SectorMark(
                    angle: .value("Count", data.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(data.color)
                .cornerRadius(5)
                .annotation(position: .overlay) {
                    VStack(spacing: 4) {
                        Text("\(data.count)")
                            .font(.title2.bold())
                        Text(data.status)
                            .font(.caption)
                    }
                    .foregroundStyle(.white)
                }
            }
            .frame(height: 250)
            .chartBackground { _ in
                VStack {
                    Text("المجموع")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(list.totalItems)")
                        .font(.title.bold())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Spending Chart
    
    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("الإنفاق حسب الفئة")
                .font(.title2.bold())
            
            Chart(categoryData, id: \.category) { data in
                BarMark(
                    x: .value("Total", data.total),
                    y: .value("Category", data.category.rawValue)
                )
                .foregroundStyle(data.category.color.gradient)
                .cornerRadius(8)
                .annotation(position: .trailing) {
                    Text("\(data.total, specifier: "%.0f")")
                        .font(.caption.bold())
                }
            }
            .frame(height: CGFloat(categoryData.count * 50))
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatisticsView(
        viewModel: ShoppingListViewModel(),
        list: ShoppingList(name: "قائمة تجريبية", items: [
            ShoppingItem(name: "تفاح", quantity: 2, price: 10.0, category: .fruits),
            ShoppingItem(name: "حليب", quantity: 1, price: 15.0, category: .dairy, isPurchased: true),
            ShoppingItem(name: "خبز", quantity: 3, price: 5.0, category: .bakery),
            ShoppingItem(name: "دجاج", quantity: 1, price: 30.0, category: .meat, isPurchased: true)
        ])
    )
}
