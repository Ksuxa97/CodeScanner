//
//  ScanDetailView.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI

struct ScanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: Coordinator
    @ObservedObject var viewModel: ScanDetailViewModel
    var onUpdate: (() -> Void)?

    var body: some View {
        NavigationView {
            Form {
                infoSection
                if viewModel.scan.type == .barcode {
                    barcodeSection
                } else {
                    qrSection
                }
                actionSection
            }
            .navigationTitle(viewModel.scan.customName ?? viewModel.scan.title ?? "Детали")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.saveName(onUpdate: onUpdate)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShare) {
                ActivityView(activityItems: [viewModel.shareText()])
            }
        }
    }

    private var infoSection: some View {
        Section(header: Text("Инфо")) {
            Text("Код: \(viewModel.scan.code)")
            Text("Тип: \(viewModel.scan.type == .qr ? "QR" : "Штрихкод")")
            Text("Дата: \(viewModel.formattedDate(viewModel.scan.date))")
            TextField("Название (локальное)", text: $viewModel.editingName, onCommit: {
                viewModel.saveName(onUpdate: onUpdate)
            })
        }
    }

    private var barcodeSection: some View {
        Section(header: Text("Продукт")) {
            Text("Название: \(viewModel.scan.title ?? "-")")
            Text("Бренд: \(viewModel.scan.brand ?? "-")")
            Text("Nutri-Score: \(viewModel.scan.nutriScore ?? "-")")
            Text("Ингредиенты:\n\(viewModel.scan.ingredients ?? "-")")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var qrSection: some View {
        Section(header: Text("Содержимое")) {
            if let raw = viewModel.scan.rawContent {
                Text(raw)
                    .lineLimit(nil)
                if let url = URL(string: raw), UIApplication.shared.canOpenURL(url) {
                    Button("Открыть ссылку") {
                        viewModel.openURLIfPossible()
                    }
                }
            } else {
                Text("-")
            }
        }
    }

    private var actionSection: some View {
        Section {
            Button("Поделиться") {
                viewModel.showShare = true
            }
            Button("Закрыть") {
                dismiss()
            }
        }
    }
}
