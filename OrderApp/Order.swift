//
//  Order.swift
//  OrderApp
//
//  Created by Christian Manzaraz on 02/05/2023.
//

import Foundation

struct Order: Codable {
    var menuItems: [MenuItem]
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}
