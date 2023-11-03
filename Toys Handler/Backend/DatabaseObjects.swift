//
//  DonationBoxDatabase.swift
//  Toys Handler
//
//  Created by Rohit Raju on 10/1/23.
//

import Foundation
import UIKit


final class TransactionsHandler: ObservableObject {
    static let standard = TransactionsHandler()
    @Published var transactions: [Transaction] = []
}

final class SuperItemsHandler: ObservableObject {
    static let standard = SuperItemsHandler()
    
    @Published var items: [Item] = []
    var staticItems: [Item] = []
    
    func updateItem(index: Int) {
        print("Value changed")
        FirebaseFunctions().updateItem(item: items[index], index: index)
    }
    
    func removeItem(at offsets: IndexSet) {
        FirebaseFunctions().deleteItem(item: items[offsets.first!])
        items.remove(atOffsets: offsets)
        staticItems.remove(atOffsets: offsets)
    }
}

struct Item: Identifiable, Equatable {
    var id: String
    var Name: String
    var Price: String
    var QuantityAvailable: Int
    var QuantityReserved: Int
    var QuantityGiven: Int
}

struct NewItem: Codable {
    var Name: String
    var Price: String
    var QuantityAvailable: Int
    var QuantityReserved: Int = 0
    var QuantityGiven: Int = 0
}

struct Transaction: Codable, Identifiable {
    var id = UUID().uuidString
    var Date: String = ""
    var Body: String = ""
    var `Type`: String = ""
}

