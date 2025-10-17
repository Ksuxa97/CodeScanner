//
//  ScanListViewModel.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Combine
import Foundation

@MainActor
final class ScanListViewModel: ObservableObject {

    @Published var scans: [ScannedCodeModel] = []
    @Published var selectedCode: ScannedCodeModel?
    @Published var alertMessage: String?

    private var codeStorage: StorageManagerProtocol

    init(storage: StorageManagerProtocol = StorageManager.shared) {
        self.codeStorage = storage
    }

    func loadScans() async {
        do {
            scans = try await codeStorage.fetch()
        } catch {
            alertMessage = "Не удалось загрузить: \(error.localizedDescription)"
        }
    }

    func deleteScans(at offsets: IndexSet) async {
        await withTaskGroup(of: Void.self) { group in
            for index in offsets {
                group.addTask {
                    await self.deleteScan(at: index)
                }
            }
        }
    }

    func selectScan(_ scan: ScannedCodeModel) {
        selectedCode = scan
    }

    func clearSelection() {
        selectedCode = nil
    }

    // MARK: - Formatting

    func displayTitle(for scan: ScannedCodeModel) -> String {
        if let name = scan.customName, name != "" {
            return name
        } else {
            return scan.title ?? defaultTitle(for: scan)
        }

    }

    func displaySubtitle(for scan: ScannedCodeModel) -> String {
        let typeString = scan.type == .qr ? "QR" : "Штрихкод"
        return "\(typeString) - \(formattedDate(scan.date))"
    }

    private func deleteScan(at index: Int) async {
        guard scans.indices.contains(index) else { return }

        let scanToDelete = scans[index]

        do {
            try await codeStorage.delete(code: scanToDelete.code)
            await loadScans() // Перезагружаем список
        } catch {
            alertMessage = "Ошибка удаления: \(error.localizedDescription)"
        }
    }

    private func defaultTitle(for scan: ScannedCodeModel) -> String {
        switch scan.type {
        case .qr:
            return scan.rawContent ?? "QR"
        case .barcode:
            return scan.code
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
