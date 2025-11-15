//
//  Extensions.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

// MARK: - View Extensions

extension View {
    /// إضافة تأثير الاهتزاز
    func shake(trigger: Bool) -> some View {
        self.modifier(ShakeEffect(shakes: trigger ? 3 : 0))
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: 10 * sin(shakes * .pi * 2), y: 0)
        )
    }
}

// MARK: - String Extensions

extension String {
    /// تنظيف الأسعار من الرموز غير الضرورية
    func cleanedPrice() -> String {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        return self.components(separatedBy: allowedCharacters.inverted).joined()
    }
    
    /// تحويل النص إلى رقم
    var toDouble: Double? {
        let cleaned = self.cleanedPrice()
        return Double(cleaned)
    }
}

// MARK: - Date Extensions

extension Date {
    /// تنسيق التاريخ بالعربية
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: self)
    }
    
    /// الحصول على اسم الشهر
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: self)
    }
    
    /// التحقق من كون التاريخ اليوم
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// التحقق من كون التاريخ هذا الأسبوع
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// التحقق من كون التاريخ هذا الشهر
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
}

// MARK: - Double Extensions

extension Double {
    /// تنسيق الرقم كعملة
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SAR"
        formatter.locale = Locale(identifier: "ar_SA")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self) ريال"
    }
    
    /// تقريب الرقم لمنزلتين عشريتين
    var rounded: Double {
        (self * 100).rounded() / 100
    }
}

// MARK: - Color Extensions

extension Color {
    /// ألوان مخصصة للتطبيق
    static let appPrimary = Color.blue
    static let appSecondary = Color.green
    static let appAccent = Color.purple
    
    /// الحصول على لون فاتح من اللون الحالي
    func lighter(by percentage: Double = 0.3) -> Color {
        self.opacity(1 - percentage)
    }
    
    /// الحصول على لون غامق من اللون الحالي
    func darker(by percentage: Double = 0.3) -> Color {
        self.opacity(1 + percentage)
    }
}

// MARK: - Array Extensions

extension Array where Element == ShoppingItem {
    /// حساب المجموع الكلي
    var totalCost: Double {
        reduce(0) { $0 + $1.totalPrice }
    }
    
    /// الحصول على المنتجات المشتراة
    var purchased: [ShoppingItem] {
        filter { $0.isPurchased }
    }
    
    /// الحصول على المنتجات غير المشتراة
    var unpurchased: [ShoppingItem] {
        filter { !$0.isPurchased }
    }
    
    /// تجميع حسب الفئة
    var groupedByCategory: [ShoppingItem.Category: [ShoppingItem]] {
        Dictionary(grouping: self, by: { $0.category })
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let itemAdded = Notification.Name("itemAdded")
    static let itemPurchased = Notification.Name("itemPurchased")
    static let listCompleted = Notification.Name("listCompleted")
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    /// مفاتيح التخزين
    enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let preferredCurrency = "preferredCurrency"
        static let enableNotifications = "enableNotifications"
        static let enableHaptics = "enableHaptics"
    }
    
    var hasSeenOnboarding: Bool {
        get { bool(forKey: Keys.hasSeenOnboarding) }
        set { set(newValue, forKey: Keys.hasSeenOnboarding) }
    }
    
    var enableHaptics: Bool {
        get { bool(forKey: Keys.enableHaptics) }
        set { set(newValue, forKey: Keys.enableHaptics) }
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
