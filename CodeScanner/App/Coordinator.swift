//
//  Coordinator.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Foundation

enum Route: Hashable {
    case scanner
}

final class Coordinator: ObservableObject {

    @Published var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
