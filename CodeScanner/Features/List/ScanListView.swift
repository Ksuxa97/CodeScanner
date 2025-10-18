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
        .overlay(
            Group {
                if viewModel.scans.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Отсканируйте код")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        )
        .navigationTitle("Список кодов")
        .onAppear {
            Task {
                await viewModel.loadScans()
            }
        }
        .alert("Ошибка", isPresented: showAlert) {
            Button("OK") { }
        } message: {
            if let message = viewModel.alertMessage {
                Text(message)
            }
        }
    }

    private var showAlert: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: {
                if !$0 {
                    viewModel.alertMessage = nil
                }
            }
        )
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
