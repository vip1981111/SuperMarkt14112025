//
//  SettingsView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("preferredCurrency") private var preferredCurrency = "SAR"
    @State private var showingOnboarding = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                // App Settings
                Section("إعدادات التطبيق") {
                    Toggle(isOn: $enableHaptics) {
                        Label("ردود الفعل اللمسية", systemImage: "hand.tap.fill")
                    }
                    
                    Toggle(isOn: $enableNotifications) {
                        Label("الإشعارات", systemImage: "bell.fill")
                    }
                    
                    Picker(selection: $preferredCurrency) {
                        Text("ريال سعودي (SAR)").tag("SAR")
                        Text("درهم إماراتي (AED)").tag("AED")
                        Text("دينار كويتي (KWD)").tag("KWD")
                        Text("دولار أمريكي (USD)").tag("USD")
                    } label: {
                        Label("العملة", systemImage: "banknote.fill")
                    }
                }
                
                // Display Settings
                Section("العرض") {
                    NavigationLink {
                        Text("إعدادات العرض قريباً")
                    } label: {
                        Label("المظهر", systemImage: "paintbrush.fill")
                    }
                    
                    NavigationLink {
                        Text("إعدادات اللغة قريباً")
                    } label: {
                        Label("اللغة", systemImage: "globe")
                    }
                }
                
                // Data Management
                Section("إدارة البيانات") {
                    Button {
                        // Export data
                    } label: {
                        Label("تصدير البيانات", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // Import data
                    } label: {
                        Label("استيراد البيانات", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(role: .destructive) {
                        // Clear all data
                    } label: {
                        Label("مسح جميع البيانات", systemImage: "trash.fill")
                    }
                }
                
                // Help & Support
                Section("المساعدة والدعم") {
                    Button {
                        showingOnboarding = true
                    } label: {
                        Label("دليل الاستخدام", systemImage: "book.fill")
                    }
                    
                    Button {
                        showingAbout = true
                    } label: {
                        Label("حول التطبيق", systemImage: "info.circle.fill")
                    }
                    
                    Link(destination: URL(string: "mailto:support@example.com")!) {
                        Label("تواصل معنا", systemImage: "envelope.fill")
                    }
                }
                
                // App Info
                Section("معلومات التطبيق") {
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("رقم البناء")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("الإعدادات")
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView(isPresented: $showingOnboarding)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image(systemName: "cart.fill.badge.plus")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                    
                    // App Name
                    Text("قائمة التسوق الذكية")
                        .font(.title.bold())
                    
                    Text("الإصدار 1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("تطبيق متقدم لإدارة قوائم التسوق")
                            .font(.headline)
                        
                        Text("يساعدك هذا التطبيق على تنظيم مشترياتك، تتبع النفقات، واستخدام الكاميرا لمسح الأسعار تلقائياً.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("الميزات الرئيسية")
                            .font(.headline)
                        
                        FeatureRow(icon: "list.bullet", title: "إدارة قوائم متعددة")
                        FeatureRow(icon: "camera.fill", title: "مسح الأسعار بالكاميرا")
                        FeatureRow(icon: "chart.bar.fill", title: "إحصائيات تفصيلية")
                        FeatureRow(icon: "folder.fill", title: "تنظيم حسب الفئات")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    // Copyright
                    Text("© 2025 جميع الحقوق محفوظة")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("حول التطبيق")
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
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
        }
    }
}

#Preview("Settings") {
    SettingsView()
}

#Preview("About") {
    AboutView()
}
