//
//  MainView.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var scannerVM = ScannerViewModel()
    @StateObject private var listVM = ScanListViewModel()
    @EnvironmentObject private var coordinator: Coordinator

    var body: some View {
        NavigationStack(path: $coordinator.path){
            ScanListView(viewModel: listVM)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            coordinator.push(.scanner)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .scanner:
                        ScannerView(viewModel: scannerVM)
                            .edgesIgnoringSafeArea(.all)
                            .background(scannerVM.showingPermissionAlert ? Color.black.opacity(0.5) : Color.clear)
                            .overlay(ScannerView(viewModel: scannerVM).alertOverlay())
                            .onAppear() {
                                scannerVM.resetScanState()
                            }
                            .onChange(of: scannerVM.lastScanned) { code in
                                guard let code = code else { return }
                                coordinator.pop()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.listVM.selectScan(code)
                                    scannerVM.resetScanState()
                                }
                            }
                    }
                }
            .sheet(item: $listVM.selectedCode) { code in
                let detailVM = ScanDetailViewModel(code: code)
                ScanDetailView(viewModel: detailVM) {
                    Task {
                        await listVM.loadScans()
                    }
                }
                .environmentObject(coordinator)
            }
        }
        .navigationBarHidden(false)
    }
}
