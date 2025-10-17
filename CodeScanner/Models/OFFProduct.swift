//
//  OFFProduct.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

struct OFFProductResponse: Codable {
    struct Product: Codable {
        let product_name: String?
        let brands: String?
        let ingredients_text: String?
        let nutriscore_grade: String?
    }
    let status: Int
    let product: Product?
}
