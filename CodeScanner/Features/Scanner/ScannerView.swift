//
//  ScannerView.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI
import AVFoundation

struct ScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    private let sessionManager = CameraSessionManager()

    func makeCoordinator() -> CameraCoordinator {
        CameraCoordinator(viewModel: viewModel, sessionManager: sessionManager)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        context.coordinator.setupUI(on: vc.view)
        return vc
    }

    func alertOverlay() -> some View {
        EmptyView()
            .alert("Нет доступа к камере",
                   isPresented: $viewModel.showingPermissionAlert) {
                Button("Настройки") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Разрешите доступ к камере в настройках, чтобы использовать сканер.")
            }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
