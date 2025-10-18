//
//  OFFProduct.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

struct OFFProductResponse: Codable {
    let status: Int
    let product: Product?
}

struct Product: Codable {
    let name: String?
    let brand: String?
    let ingredients: String?
    let nutriscore: String?

    enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case brand = "brands"
        case ingredients = "ingredients_text"
        case nutriscore = "nutriscore_grade"
    }
}
