//
//  CameraService.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 17.10.2025.
//

import AVFoundation
import UIKit

final class CameraService {

    weak var metadataDelegate: AVCaptureMetadataOutputObjectsDelegate?

    private var session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func start(on view: UIView) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            configureSession(on: view)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.configureSession(on: view)
                            : NotificationCenter.default.post(name: .cameraPermissionDenied, object: nil)
                }
            }
        case .denied, .restricted:
            NotificationCenter.default.post(name: .cameraPermissionDenied, object: nil)
        @unknown default:
            break
        }
    }

    func stop() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }

    func toggleTorch(isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if isOn {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error)")
        }
    }

    // MARK: - Private Methods

    private func configureSession(on view: UIView) {

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            NotificationCenter.default.post(name: .cameraUnavailable, object: nil)
            return
        }

        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(metadataDelegate, queue: .main)
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .upce, .code128, .code39, .code93]
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                let preview = AVCaptureVideoPreviewLayer(session: self.session)
                preview.videoGravity = .resizeAspectFill
                preview.frame = view.bounds
                view.layer.insertSublayer(preview, at: 0)
                self.previewLayer = preview
            }
        }
    }
}


// MARK: - Notifications
extension Notification.Name {
    static let cameraPermissionDenied = Notification.Name("CameraPermissionDenied")
    static let cameraUnavailable = Notification.Name("CameraUnavailable")
}
