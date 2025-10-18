//
//  ActivityView.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIActivityViewController {

        let controller = UIActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: applicationActivities
                )
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            dismiss()
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
