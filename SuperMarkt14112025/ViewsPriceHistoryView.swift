//
//  PriceHistoryView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI

struct PriceHistoryView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Card
                    VStack(spacing: 12) {
                        Text("المجموع الكلي")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(String(format: "%.2f ريال", cameraViewModel.totalScanned))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("\(cameraViewModel.scannedPrices.count) عنصر")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green.opacity(0.1))
                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                    )
                    .padding(.horizontal)
                    
                    // Prices List
                    if !cameraViewModel.scannedPrices.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("قائمة الأسعار")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(cameraViewModel.scannedPrices.enumerated().reversed()), id: \.offset) { index, price in
                                HStack {
                                    // Number
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.gradient)
                                            .frame(width: 40, height: 40)
                                        
                                        Text("\(cameraViewModel.scannedPrices.count - index)")
                                            .font(.headline.bold())
                                            .foregroundStyle(.white)
                                    }
                                    
                                    // Price
                                    Text(String(format: "%.2f ريال", price))
                                        .font(.title3.monospacedDigit())
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    // Delete Button
                                    Button(role: .destructive) {
                                        withAnimation {
                                            let actualIndex = cameraViewModel.scannedPrices.count - 1 - index
                                            cameraViewModel.removePrice(at: actualIndex)
                                        }
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("لم تضف أي أسعار بعد")
                                .font(.title3.bold())
                            
                            Text("استخدم الكاميرا أو الإدخال اليدوي لإضافة الأسعار")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("قائمة الأسعار")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") {
                        dismiss()
                    }
                }
                
                if !cameraViewModel.scannedPrices.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                shareTotal()
                            } label: {
                                Label("مشاركة المجموع", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    cameraViewModel.clearAll()
                                }
                            } label: {
                                Label("مسح الكل", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
    
    private func shareTotal() {
        let pricesList = cameraViewModel.scannedPrices.enumerated()
            .map { String(format: "%d. %.2f ريال", $0.offset + 1, $0.element) }
            .joined(separator: "\n")
        
        let text = """
        مجموع التسوق: \(String(format: "%.2f", cameraViewModel.totalScanned)) ريال
        عدد العناصر: \(cameraViewModel.scannedPrices.count)
        
        تفاصيل الأسعار:
        \(pricesList)
        """
        
        let activityController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

#Preview {
    PriceHistoryView(cameraViewModel: {
        let vm = CameraViewModel()
        vm.scannedPrices = [12.50, 25.00, 8.75, 30.00, 15.25]
        return vm
    }())
}
