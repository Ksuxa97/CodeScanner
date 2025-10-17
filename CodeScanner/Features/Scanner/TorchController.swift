//
//  TorchController.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 17.10.2025.
//

import UIKit

final class TorchController {

    private weak var button: UIButton?
    private let viewModel: ScannerViewModel
    private let cameraService: CameraService

    init(viewModel: ScannerViewModel, cameraService: CameraService) {
        self.viewModel = viewModel
        self.cameraService = cameraService
    }

    @MainActor
    func attach(to view: UIView) {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        button.setImage(UIImage(systemName: "flashlight.on.circle", withConfiguration: config), for: .normal)

        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let newState = !self.viewModel.isTorchOn
            self.cameraService.toggleTorch(isOn: newState)
            self.viewModel.isTorchOn = newState
        }, for: .touchUpInside)

        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])

        self.button = button
    }

    @MainActor
    func updateButtonState(isOn: Bool) {
        guard let button else { return }
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        let imageName = isOn ? "flashlight.off.circle.fill" : "flashlight.on.circle"
        button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
}
