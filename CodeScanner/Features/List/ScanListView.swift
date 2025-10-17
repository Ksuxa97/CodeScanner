//
//  ScanListView.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI

struct ScanListView: View {
    @ObservedObject var viewModel: ScanListViewModel

    var body: some View {
        List {
            ForEach(viewModel.scans) { item in
                scanRow(for: item)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Список кодов")
        .onAppear {
            Task {
                await viewModel.loadScans()
            }
        }
        .alert("Ошибка", isPresented: .constant(viewModel.alertMessage != nil)) {
            Button("OK") {
                viewModel.alertMessage = nil
            }
        } message: {
            if let message = viewModel.alertMessage {
                Text(message)
            }
        }
    }

    // MARK: - Private Views

    private func scanRow(for item: ScannedCodeModel) -> some View {
        Button {
            viewModel.selectScan(item)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.displayTitle(for: item))
                        .font(.headline)
                    Text(viewModel.displaySubtitle(for: item))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Private Methods

    private func deleteItems(at offsets: IndexSet) {
        Task {
            await viewModel.deleteScans(at: offsets)
        }
    }
}
