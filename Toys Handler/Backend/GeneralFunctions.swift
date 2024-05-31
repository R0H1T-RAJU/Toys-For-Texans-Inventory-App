//
//  GeneralFunctions.swift
//  Toys Handler
//
//  Created by Rohit Raju on 5/30/24.
//

import Foundation

func getTotalItems(items: [Item]) -> Int {
    var totalItems: Int = 0
    for item in items {
        totalItems += Int(item.QuantityAvailable) ?? 0
    }
    return totalItems
}

func getTotalPrice(items: [Item]) -> Double {
    var totalPrice: Double = 0
    for item in items {
        let itemQuantity: Double = Double(item.QuantityAvailable) ?? 0
        let itemPrice: Double = Double(item.Price) ?? 0
        let itemTotalPrice = itemQuantity * itemPrice
        totalPrice += round(itemTotalPrice * 100) / 100
    }
    return totalPrice
}

@MainActor func getTotalPrice(donationBox: DonationBox) -> Double {
    var totalPrice: Double = 0
    let itemsHandler: SuperItemsHandler = .standard
    let items: [Item] = itemsHandler.items.filter{$0.DonationBoxId == donationBox.id}
    for item in items {
        let itemQuantity: Double = Double(item.QuantityAvailable) ?? 0
        let itemPrice: Double = Double(item.Price) ?? 0
        let itemTotalPrice = itemQuantity * itemPrice
        totalPrice += round(itemTotalPrice * 100) / 100
    }
    return totalPrice
}
