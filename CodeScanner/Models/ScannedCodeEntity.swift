//
//  ScannedCodeEntity.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//
import Foundation

extension ScannedCodeEntity {
    func toScannedCodeModel() -> ScannedCodeModel {
        return ScannedCodeModel(
            id: UUID(),
            code: code ?? "",
            type: type == "qr" ? .qr : .barcode,
            customName: customName,
            title: title,
            brand: brand,
            ingredients: ingredients,
            nutriScore: nutriScore,
            rawContent: rawContent,
            date: date ?? Date()
        )
    }
}
