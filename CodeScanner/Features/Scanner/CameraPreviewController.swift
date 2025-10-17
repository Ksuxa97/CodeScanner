//
//  CameraPreviewController.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 17.10.2025.
//

import AVFoundation
import UIKit
import Combine

final class CameraPreviewController: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    private let viewModel: ScannerViewModel
    private let cameraService: CameraService
    private let torchController: TorchController
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ScannerViewModel, cameraService: CameraService) {
        self.viewModel = viewModel
        self.cameraService = cameraService
        self.torchController = TorchController(viewModel: viewModel, cameraService: cameraService)
    }

    @MainActor
    func configure(on view: UIView) {
        cameraService.metadataDelegate = self
        cameraService.start(on: view)
        addOverlay(to: view)
        torchController.attach(to: view)
        subscribeToTorchState()
        setupNotifications()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }

        let type: CodeType = (object.type == .qr) ? .qr : .barcode
        cameraService.stop()

        Task { @MainActor [weak viewModel] in
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

    @MainActor
    private func subscribeToTorchState() {
        viewModel.$isTorchOn
            .receive(on: RunLoop.main)
            .sink { [weak self] isOn in
                self?.torchController.updateButtonState(isOn: isOn)
            }
            .store(in: &cancellables)
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

    @MainActor
    private func handleError(_ message: String) {
        viewModel.errorMessage = message
        viewModel.showingPermissionAlert = true
    }
}
