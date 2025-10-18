//
//  ScannedCodeModel.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Foundation

struct ScannedCodeModel: Equatable, Identifiable, Hashable {
    var id: UUID
    let code: String
    let type: CodeType
    var customName: String?
    var title: String?
    var brand: String?
    var ingredients: String?
    var nutriScore: String?
    var rawContent: String?
    let date: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum CodeType: String {
    case barcode
    case qr
}
