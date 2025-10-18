//
//  CameraPreviewController.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 17.10.2025.
//

import AVFoundation
import UIKit
import Combine

@MainActor
final class CameraPreviewController: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    private let viewModel: ScannerViewModel
    private let cameraService: CameraService
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ScannerViewModel, cameraService: CameraService) {
        self.viewModel = viewModel
        self.cameraService = cameraService
    }

    func configure(on view: UIView) {
        cameraService.metadataDelegate = self
        cameraService.start(on: view)
        addOverlay(to: view)
        setupNotifications()
    }

    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }

        let type: CodeType = (object.type == .qr) ? .qr : .barcode

        Task { @MainActor [weak viewModel] in
            cameraService.stop()
            viewModel?.handleScanned(code: stringValue, type: type)
        }
    }

    // MARK: - Private Methods

    private func addOverlay(to view: UIView) {
        let overlay = UIView()
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        overlay.layer.borderColor = UIColor.white.cgColor
        overlay.layer.borderWidth = 2
        overlay.layer.cornerRadius = 12
        overlay.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            overlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overlay.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            overlay.heightAnchor.constraint(equalTo: overlay.widthAnchor, multiplier: 0.6)
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .cameraPermissionDenied,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleError("Доступ к камере запрещён")
            }
        }

        NotificationCenter.default.addObserver(
            forName: .cameraUnavailable,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleError("Камера недоступна")
            }
        }
    }

    private func handleError(_ message: String) {
        viewModel.errorMessage = message
        viewModel.showingPermissionAlert = true
    }
}
