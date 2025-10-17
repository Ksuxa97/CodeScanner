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
    private let cameraService = CameraService()

    func alertOverlay() -> some View {
        EmptyView()
            .alert(
                "Нет доступа к камере",
                isPresented: $viewModel.showingPermissionAlert
            ) {
                Button("Настройки") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Разрешите доступ к камере в настройках, чтобы использовать сканер.")
            }
    }

    func makeCoordinator() -> CameraPreviewController {
        CameraPreviewController(viewModel: viewModel, cameraService: cameraService)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        context.coordinator.configure(on: controller.view)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
