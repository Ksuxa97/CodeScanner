//
//  OpenFoodFactsService.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Foundation

enum APIConstants {
    static let baseURL: String = "https://world.openfoodfacts.org"
}

enum Endpoint {
    case barcode(code: String)

    var url: URL? {
        switch self {
        case .barcode(let barcode):
            let urlComponents = URLComponents(string: APIConstants.baseURL + "/api/v0/product/\(barcode).json")
            return urlComponents?.url
        }
    }
}

protocol ApiServiceProtocol {
    func fetchProduct(barcode: String) async throws -> Product?
}

final class OpenFoodFactsService: ApiServiceProtocol {

    func fetchProduct(barcode: String) async throws -> Product? {

        guard let url = Endpoint.barcode(code: barcode).url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(OFFProductResponse.self, from: data)
        if let product = decoded.product {
            return (product)
        } else {
            return (nil)
        }
    }
}
