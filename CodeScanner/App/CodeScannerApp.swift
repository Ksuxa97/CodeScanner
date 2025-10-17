//
//  CodeScannerApp.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import SwiftUI

@main
struct CodeScannerApp: App {
    @StateObject private var coordinator: Coordinator = Coordinator()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(coordinator)
        }
    }
}

