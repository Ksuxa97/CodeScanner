//
//  ScannerView.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    @StateObject private var cameraService = CameraService()

    var body: some View {
        ZStack {
            CameraViewRepresentable(
                viewModel: viewModel,
                cameraService: cameraService
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TorchButton(
                        viewModel: viewModel,
                        cameraService: cameraService
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert(
            "Нет доступа к камере",
            isPresented: $viewModel.showingPermissionAlert
        ) {
            Button("Настройки") {
                viewModel.openSettings()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Разрешите доступ к камере в настройках, чтобы использовать сканер.")
        }
    }
}


struct CameraViewRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    let cameraService: CameraService

    func makeCoordinator() -> CameraPreviewController {
        CameraPreviewController(viewModel: viewModel, cameraService: cameraService)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        context.coordinator.configure(on: controller.view)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
