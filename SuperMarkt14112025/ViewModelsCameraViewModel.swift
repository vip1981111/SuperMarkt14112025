//
//  CameraViewModel.swift
//  SuperMarkt14112025
//
//  Created by MOHAMMED ABDULLAH on 14/11/2025.
//

import Foundation
import AVFoundation
import Vision
import SwiftUI
import Combine

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    static let shared = CameraViewModel()
    
    @Published var scannedPrices: [Double] = [] {
        didSet {
            savePrices()
        }
    }
    @Published var currentPrice: String = ""
    @Published var totalAmount: Double = 0.0
    @Published var isProcessing = false
    @Published var showCamera = false
    @Published var errorMessage: String?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let pricesKey = "SavedScannedPrices"
    
    var totalScanned: Double {
        return scannedPrices.reduce(0, +)
    }
    
    override init() {
        super.init()
        loadPrices()
    }
    
    func setupCamera() -> AVCaptureSession? {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            errorMessage = "لا يمكن الوصول إلى الكاميرا"
            return nil
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        self.captureSession = session
        self.videoOutput = output
        
        return session
    }
    
    func startScanning() {
        Task {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                Task { @MainActor in
                    self.captureSession?.startRunning()
                }
            }
        }
    }
    
    func stopScanning() {
        Task {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                Task { @MainActor in
                    self.captureSession?.stopRunning()
                }
            }
        }
    }
    
    func addCurrentPrice() {
        if let price = Double(currentPrice), price > 0 {
            scannedPrices.append(price)
            totalAmount = totalScanned
            currentPrice = ""
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func removePrice(at index: Int) {
        scannedPrices.remove(at: index)
        totalAmount = totalScanned
    }
    
    func clearAll() {
        scannedPrices.removeAll()
        currentPrice = ""
        totalAmount = 0.0
    }
    
    // MARK: - Persistence
    
    private func savePrices() {
        UserDefaults.standard.set(scannedPrices, forKey: pricesKey)
        totalAmount = totalScanned
    }
    
    private func loadPrices() {
        if let saved = UserDefaults.standard.array(forKey: pricesKey) as? [Double] {
            scannedPrices = saved
            totalAmount = totalScanned
        }
    }
    
    nonisolated private func recognizeText(in image: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            Task { @MainActor in
                self.processObservations(observations)
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "ar-SA"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            Task { @MainActor [weak self] in
                self?.errorMessage = "خطأ في معالجة الصورة"
            }
        }
    }
    
    @MainActor
    private func processObservations(_ observations: [VNRecognizedTextObservation]) {
        guard !isProcessing else { return }
        
        var foundPrices: [Double] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string
            
            // البحث عن الأرقام في النص
            let numbers = extractNumbers(from: text)
            foundPrices.append(contentsOf: numbers)
        }
        
        if let price = foundPrices.first, !currentPrice.isEmpty == false {
            currentPrice = String(format: "%.2f", price)
            isProcessing = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.isProcessing = false
            }
        }
    }
    
    nonisolated private func extractNumbers(from text: String) -> [Double] {
        var numbers: [Double] = []
        
        // البحث عن أنماط الأسعار
        let patterns = [
            #"(\d+[.,]\d{1,2})"#,  // 10.50 or 10,50
            #"(\d+)"#               // 10
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsString = text as NSString
                let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        var numberString = String(text[range])
                        numberString = numberString.replacingOccurrences(of: ",", with: ".")
                        
                        if let number = Double(numberString), number > 0 && number < 10000 {
                            numbers.append(number)
                        }
                    }
                }
            }
        }
        
        return numbers
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        recognizeText(in: pixelBuffer)
    }
}
