//
//  ScannerViewModel.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Foundation
import Combine
import AVFoundation

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var lastScanned: ScannedCodeModel?
    @Published var errorMessage: String?
    @Published var showingPermissionAlert = false
    @Published var isTorchOn = false

    private var codeStorage: StorageManagerProtocol
    private var recentlyScannedCodes = Set<String>()

    init(storage: StorageManagerProtocol = StorageManager.shared) {
        self.codeStorage = storage
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

    private func processScanned(code: String, type: CodeType) async {
        let id = UUID()
        var model = ScannedCodeModel(id: id, code: code, type: type, date: Date())
        if type == .barcode {
            do {
                let info = try await OpenFoodFactsService.shared.fetchProduct(barcode: code)
                model.title = info.title
                model.brand = info.brand
                model.ingredients = info.ingredients
                model.nutriScore = info.nutriScore
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
