//
//  CameraView.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraViewModel = CameraViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingManualEntry = false
    @State private var showingPriceHistory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview
                CameraPreviewView(session: cameraViewModel.setupCamera())
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Current Price Display
                    if !cameraViewModel.currentPrice.isEmpty {
                        Text(cameraViewModel.currentPrice)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Bottom Controls
                    VStack(spacing: 16) {
                        // Total Display
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("المجموع الكلي")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(cameraViewModel.totalScanned, specifier: "%.2f") ريال")
                                    .font(.title2.bold())
                            }
                            
                            Spacer()
                            
                            Text("\(cameraViewModel.scannedPrices.count) عنصر")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            // Manual Entry
                            Button {
                                showingManualEntry = true
                            } label: {
                                Label("إدخال يدوي", systemImage: "keyboard")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            // Add Current Price
                            Button {
                                cameraViewModel.addCurrentPrice()
                            } label: {
                                Label("إضافة", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(cameraViewModel.currentPrice.isEmpty)
                            
                            // View List
                            Button {
                                showingPriceHistory = true
                            } label: {
                                Image(systemName: "list.bullet")
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                        }
                        .controlSize(.large)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("تسوق بالمبلغ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") {
                        dismiss()
                    }
                    .bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            cameraViewModel.clearAll()
                        } label: {
                            Label("مسح الكل", systemImage: "trash")
                        }
                        
                        Button {
                            // Share total
                        } label: {
                            Label("مشاركة", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualPriceEntryView(cameraViewModel: cameraViewModel)
            }
            .sheet(isPresented: $showingPriceHistory) {
                PriceHistoryView(cameraViewModel: cameraViewModel)
            }
            .onAppear {
                cameraViewModel.startScanning()
            }
            .onDisappear {
                cameraViewModel.stopScanning()
            }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession?
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.session = session
    }
}

class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Manual Price Entry

struct ManualPriceEntryView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var priceInput = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Price Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("المبلغ")
                        .font(.headline)
                    
                    TextField("0.00", text: $priceInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Scanned Prices List
                if !cameraViewModel.scannedPrices.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("المبالغ المضافة")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(cameraViewModel.scannedPrices.enumerated()), id: \.offset) { index, price in
                                    HStack {
                                        Text("\(index + 1).")
                                            .foregroundStyle(.secondary)
                                        
                                        Text("\(price, specifier: "%.2f") ريال")
                                            .font(.body.monospacedDigit())
                                        
                                        Spacer()
                                        
                                        Button(role: .destructive) {
                                            cameraViewModel.removePrice(at: index)
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                }
                
                Spacer()
                
                // Add Button
                Button {
                    if let price = Double(priceInput), price > 0 {
                        cameraViewModel.scannedPrices.append(price)
                        cameraViewModel.totalAmount = cameraViewModel.totalScanned
                        priceInput = ""
                        isFocused = true
                    }
                } label: {
                    Label("إضافة المبلغ", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(priceInput.isEmpty || Double(priceInput) == nil)
            }
            .padding()
            .navigationTitle("إدخال يدوي")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

#Preview {
    CameraView()
}
