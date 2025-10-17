//
//  CameraCoordinator.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import AVFoundation
import UIKit
import Combine

final class CameraCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    private let viewModel: ScannerViewModel
    private let sessionManager: CameraSessionManager
    private var cancellables = Set<AnyCancellable>()
    private weak var torchButton: UIButton?

    init(viewModel: ScannerViewModel, sessionManager: CameraSessionManager) {
        self.viewModel = viewModel
        self.sessionManager = sessionManager
    }

    // MARK: - AVCapture Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }

        let type: CodeType = (object.type == .qr) ? .qr : .barcode
        sessionManager.stopSession()
        
        Task { @MainActor [weak viewModel] in
            print("Сканирован код: \(stringValue)")
            viewModel?.handleScanned(code: stringValue, type: type)
        }
    }

    // MARK: - UI Setup
    func setupUI(on view: UIView) {
        sessionManager.metadataDelegate = self
        sessionManager.configure(on: view)
        addOverlay(to: view)
        addTorchButton(to: view)
        Task { @MainActor in
            subscribeToTorchState()
        }
        setupNotifications()
    }

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

    private func addTorchButton(to view: UIView) {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "flashlight.on.circle"), for: .normal)

        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                let newState = self.viewModel.isTorchOn
                self.sessionManager.toggleTorch(isOn: newState)
                self.viewModel.isTorchOn = newState
            }
        }, for: .touchUpInside)

        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.torchButton = button
    }

    @MainActor
    private func subscribeToTorchState() {
        viewModel.$isTorchOn
            .receive(on: RunLoop.main)
            .sink { [weak self] isOn in
                guard let self, let button = self.torchButton else { return }
                let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
                let imageName = isOn ? "flashlight.off.circle" : "flashlight.on.circle"
                button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
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
                self?.viewModel.errorMessage = "Доступ к камере запрещён"
                self?.viewModel.showingPermissionAlert = true
            }
        }

        NotificationCenter.default.addObserver(
            forName: .cameraUnavailable,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.viewModel.errorMessage = "Камера недоступна"
                self?.viewModel.showingPermissionAlert = true
            }
        }
    }
}
