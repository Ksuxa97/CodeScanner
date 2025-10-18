//
//  ScannerViewModel.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var lastScanned: ScannedCodeModel?
    @Published var errorMessage: String?
    @Published var showingPermissionAlert = false
    @Published var isTorchOn = false

    private var codeStorage: StorageManagerProtocol
    private var apiService: ApiServiceProtocol
    private var application: UIApplication
    private var recentlyScannedCodes = Set<String>()

    init(storage: StorageManagerProtocol, apiService: ApiServiceProtocol, app: UIApplication) {
        self.codeStorage = storage
        self.apiService = apiService
        self.application = app
    }

    func handleScanned(code: String, type: CodeType) {
        guard !recentlyScannedCodes.contains(code) else { return }
        recentlyScannedCodes.insert(code)
        Task {
            await processScanned(code: code, type: type)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            recentlyScannedCodes.remove(code)
        }
    }

    func resetScanState() {
        lastScanned = nil
        errorMessage = nil
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            application.open(url)
        }
    }

    // MARK: - Private Methods

    private func processScanned(code: String, type: CodeType) async {
        let id = UUID()
        var model = ScannedCodeModel(id: id, code: code, type: type, date: Date())
        if type == .barcode {
            do {
                let product = try await apiService.fetchProduct(barcode: code)
                model.title = product?.name
                model.brand = product?.brand
                model.ingredients = product?.ingredients
                model.nutriScore = product?.nutriscore
            } catch {
                print("OFF fetch failed: \(error.localizedDescription)")
            }
        } else {
            model.rawContent = code
        }
        do {
            try await codeStorage.save(model: model)
            lastScanned = model
        } catch {
            errorMessage = "Не удалось сохранить: \(error.localizedDescription)"
        }
    }
}
