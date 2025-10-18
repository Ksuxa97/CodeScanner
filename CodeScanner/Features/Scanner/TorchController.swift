//
//  TorchController.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 17.10.2025.
//

import SwiftUI

struct TorchButton: View {
    @ObservedObject var viewModel: ScannerViewModel
    let cameraService: CameraService

    var body: some View {
        Button {
            let newState = !viewModel.isTorchOn
            cameraService.toggleTorch(isOn: newState)
            viewModel.isTorchOn = newState
        } label: {
            Image(systemName: viewModel.isTorchOn ? "flashlight.off.circle.fill" : "flashlight.on.circle")
                .font(.system(size: 50, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
        }
    }
}
