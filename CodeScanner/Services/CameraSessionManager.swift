//
//  CameraSessionManager.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import AVFoundation
import UIKit

final class CameraSessionManager {

    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var metadataDelegate: AVCaptureMetadataOutputObjectsDelegate?

    func configure(on view: UIView) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            startSession(on: view)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.startSession(on: view)
                    } else {
                        NotificationCenter.default.post(name: .cameraPermissionDenied, object: nil)
                    }
                }
            }
        case .denied, .restricted:
            NotificationCenter.default.post(name: .cameraPermissionDenied, object: nil)
        @unknown default:
            break
        }
    }

    private func startSession(on view: UIView) {
        let session = AVCaptureSession()
        self.session = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            NotificationCenter.default.post(name: .cameraUnavailable, object: nil)
            return
        }

        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(metadataDelegate, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .upce, .code128, .code39, .code93]
        }

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            DispatchQueue.main.async {
                let preview = AVCaptureVideoPreviewLayer(session: session)
                preview.videoGravity = .resizeAspectFill
                preview.frame = view.bounds
                view.layer.insertSublayer(preview, at: 0)
                self.previewLayer = preview
            }
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session?.stopRunning()
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
}

// MARK: - Notifications
extension Notification.Name {
    static let cameraPermissionDenied = Notification.Name("CameraPermissionDenied")
    static let cameraUnavailable = Notification.Name("CameraUnavailable")
}
