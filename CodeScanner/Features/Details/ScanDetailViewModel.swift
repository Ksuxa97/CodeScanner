//
//  ScanDetailViewModel.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI

@MainActor
final class ScanDetailViewModel: ObservableObject {
    @Published var scan: ScannedCodeModel
    @Published var editingName: String
    @Published var showShare = false

    private var codeStorage: StorageManagerProtocol

    init(code: ScannedCodeModel, storage: StorageManagerProtocol) {
        self.codeStorage = storage
        self.scan = code
        self.editingName = code.customName ?? ""
    }

    func saveName(onUpdate: (() -> Void)? = nil) {
        Task {
            do {
                let repo = StorageManager.shared
                try await repo.updateCustomName(code: scan.code, name: editingName)
                scan.customName = editingName
                onUpdate?()
            } catch {
                print("Save name error: \(error)")
            }
        }
    }

    func shareText() -> String {
        var parts: [String] = []
        parts.append("Код: \(scan.code)")
        parts.append("Тип: \(scan.type == .qr ? "QR" : "Штрихкод")")
        if let title = scan.title { parts.append("Название: \(title)") }
        if let brand = scan.brand { parts.append("Бренд: \(brand)") }
        if let ingredients = scan.ingredients { parts.append("Ингредиенты: \(ingredients)") }
        if let raw = scan.rawContent { parts.append("Содержимое: \(raw)") }
        return parts.joined(separator: "\n")
    }

    func openURLIfPossible() {
        guard let raw = scan.rawContent,
              let url = URL(string: raw),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
