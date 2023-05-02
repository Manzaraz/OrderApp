//
//  ResponseModels.swift
//  OrderApp
//
//  Created by Christian Manzaraz on 02/05/2023.
//

import Foundation

/// for /menu endpoint
struct MenuResponse: Codable {
    let items: [MenuItem]
}


/// for /categories endpoint
struct CategoriesResponse: Codable {
    let categories: [String]
}

/// for /order
struct OrderResponse: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}

