//
//  AllStatisticsView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI
import Charts

struct AllStatisticsView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var selectedTimeframe: Timeframe = .month
    
    enum Timeframe: String, CaseIterable {
        case week = "أسبوع"
        case month = "شهر"
        case year = "سنة"
        case all = "الكل"
    }
    
    private var allItems: [ShoppingItem] {
        viewModel.lists.flatMap { $0.items }
    }
    
    private var purchasedItems: [ShoppingItem] {
        allItems.filter { $0.isPurchased }
    }
    
    private var totalSpent: Double {
        purchasedItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    private var categoryBreakdown: [(category: ShoppingItem.Category, total: Double, count: Int)] {
        let grouped = Dictionary(grouping: purchasedItems, by: { $0.category })
        return grouped.map { category, items in
            let total = items.reduce(0) { $0 + $1.totalPrice }
            return (category, total, items.count)
        }
        .sorted { $0.total > $1.total }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Timeframe Picker
                    timeframePicker
                    
                    // Overview Cards
                    overviewCards
                    
                    // Spending Trend
                    spendingTrend
                    
                    // Category Breakdown
                    categoryBreakdownView
                    
                    // Most Purchased Items
                    topItemsView
                }
                .padding()
            }
            .navigationTitle("الإحصائيات العامة")
        }
    }
    
    // MARK: - Timeframe Picker
    
    private var timeframePicker: some View {
        Picker("الفترة الزمنية", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Overview Cards
    
    private var overviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "إجمالي القوائم",
                    value: "\(viewModel.lists.count)",
                    icon: "list.bullet.clipboard.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "إجمالي المنتجات",
                    value: "\(allItems.count)",
                    icon: "cart.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "المشتريات",
                    value: "\(purchasedItems.count)",
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "إجمالي الإنفاق",
                    value: String(format: "%.0f ريال", totalSpent),
                    icon: "banknote.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Spending Trend
    
    private var spendingTrend: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("اتجاه الإنفاق")
                .font(.title2.bold())
            
            if !purchasedItems.isEmpty {
                let monthlyData = getMonthlySpending()
                
                Chart(monthlyData, id: \.month) { data in
                    BarMark(
                        x: .value("الشهر", data.month),
                        y: .value("الإنفاق", data.amount)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(8)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text("\(amount, specifier: "%.0f")")
                            }
                        }
                    }
                }
            } else {
                Text("لا توجد بيانات متاحة")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Category Breakdown
    
    private var categoryBreakdownView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("التوزيع حسب الفئات")
                .font(.title2.bold())
            
            if !categoryBreakdown.isEmpty {
                Chart(categoryBreakdown, id: \.category) { data in
                    SectorMark(
                        angle: .value("Amount", data.total),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(data.category.color)
                    .cornerRadius(5)
                }
                .frame(height: 250)
                
                // Legend
                VStack(spacing: 8) {
                    ForEach(categoryBreakdown.prefix(5), id: \.category) { data in
                        HStack {
                            Circle()
                                .fill(data.category.color)
                                .frame(width: 12, height: 12)
                            
                            Text(data.category.icon + " " + data.category.rawValue)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(data.total, specifier: "%.2f") ريال")
                                .font(.subheadline.bold())
                        }
                    }
                }
                .padding(.top)
            } else {
                Text("لا توجد بيانات متاحة")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Top Items
    
    private var topItemsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("المنتجات الأكثر شراءً")
                .font(.title2.bold())
            
            let topItems = getTopPurchasedItems()
            
            if !topItems.isEmpty {
                ForEach(Array(topItems.enumerated()), id: \.offset) { index, item in
                    HStack {
                        // Rank
                        ZStack {
                            Circle()
                                .fill(rankColor(for: index).gradient)
                                .frame(width: 40, height: 40)
                            
                            Text("\(index + 1)")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                        }
                        
                        // Item Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.headline)
                            
                            Text("\(item.count) مرة • \(item.category.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Total
                        Text("\(item.total, specifier: "%.2f") ريال")
                            .font(.headline)
                            .foregroundStyle(item.category.color)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Text("لا توجد بيانات متاحة")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getMonthlySpending() -> [(month: String, amount: Double)] {
        let calendar = Calendar.current
        let months = (0..<6).compactMap { calendar.date(byAdding: .month, value: -$0, to: Date()) }
        
        return months.reversed().map { date in
            let monthItems = purchasedItems.filter {
                calendar.isDate($0.addedDate, equalTo: date, toGranularity: .month)
            }
            let total = monthItems.reduce(0) { $0 + $1.totalPrice }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            formatter.locale = Locale(identifier: "ar")
            
            return (formatter.string(from: date), total)
        }
    }
    
    private func getTopPurchasedItems() -> [(name: String, count: Int, total: Double, category: ShoppingItem.Category)] {
        let grouped = Dictionary(grouping: purchasedItems, by: { $0.name })
        return grouped.map { name, items in
            let total = items.reduce(0) { $0 + $1.totalPrice }
            return (name, items.count, total, items.first!.category)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue
        }
    }
}

#Preview {
    AllStatisticsView()
}
