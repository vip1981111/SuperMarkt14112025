//
//  OnboardingView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let features = [
        OnboardingFeature(
            icon: "list.bullet.clipboard.fill",
            title: "إدارة قوائم التسوق",
            description: "أنشئ قوائم متعددة، نظم مشترياتك، وتابع تقدمك بسهولة",
            color: .blue
        ),
        OnboardingFeature(
            icon: "cart.fill.badge.plus",
            title: "إضافة المنتجات",
            description: "أضف منتجات مع الكمية والسعر، واختر من 10 فئات مختلفة",
            color: .green
        ),
        OnboardingFeature(
            icon: "camera.fill",
            title: "تسوق بالمبلغ",
            description: "استخدم الكاميرا لمسح الأسعار تلقائياً وحساب المجموع فوراً",
            color: .purple
        ),
        OnboardingFeature(
            icon: "chart.bar.fill",
            title: "إحصائيات تفصيلية",
            description: "شاهد تقارير ورسوم بيانية لنفقاتك وتوزيع مشترياتك",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [features[currentPage].color.opacity(0.3), features[currentPage].color.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Skip Button
                HStack {
                    Spacer()
                    Button("تخطي") {
                        isPresented = false
                    }
                    .foregroundStyle(.secondary)
                    .padding()
                }
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        VStack(spacing: 24) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(feature.color.gradient)
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: feature.icon)
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                            }
                            .shadow(radius: 10)
                            
                            // Title
                            Text(feature.title)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                            
                            // Description
                            Text(feature.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 400)
                
                Spacer()
                
                // Action Button
                Button {
                    if currentPage < features.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isPresented = false
                    }
                } label: {
                    Text(currentPage < features.count - 1 ? "التالي" : "ابدأ الآن")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(features[currentPage].color.gradient)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

struct OnboardingFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
