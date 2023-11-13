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
    
    func getTransactions() async throws {
        transactions = try! await FirebaseFunctions().getTranscations()
    }
}

final class DonationBoxesHandler: ObservableObject {
    static let standard = DonationBoxesHandler()
    
    @Published var donationBoxes: [DonationBox] = []
    var staticDonationBoxes: [DonationBox] = []
    let firebaseFunctions = FirebaseFunctions()
    
    func updateDonationBox(index: Int) {
        firebaseFunctions.updateDonationBox(donationBox: donationBoxes[index], staticDonationBox: staticDonationBoxes[index], index: index)
        staticDonationBoxes[index] = donationBoxes[index]

    }
    
    func removeBox(at index: Int) {
        firebaseFunctions.deleteDonationBox(donationBox: donationBoxes[index])
        SuperItemsHandler.standard.items.removeAll{$0.DonationBoxName == donationBoxes[index].Name}
        donationBoxes.remove(at: index)
        staticDonationBoxes.remove(at: index)
    }
    
    func getBoxes() async throws {
        let donationBoxesList = try! await firebaseFunctions.getDonationBoxes()
        donationBoxes = donationBoxesList
        staticDonationBoxes = donationBoxesList
    }
}

final class SuperItemsHandler: ObservableObject {
    static let standard = SuperItemsHandler()
    
    @Published var items: [Item] = []
    var staticItems: [Item] = []
    let firebaseFunctions = FirebaseFunctions()
    
    func updateItem(index: Int) {
        firebaseFunctions.updateItem(item: items[index], staticItem: staticItems[index], index: index)
        staticItems[index] = items[index]
    }
    
    func removeItem(at index: Int) {
        firebaseFunctions.deleteItem(item: items[index])
        items.remove(at: index)
        staticItems.remove(at: index)
    }
    
    func getItems() async throws {
        let itemList = try! await firebaseFunctions.getItems()
        items = itemList
        staticItems = itemList
    }
}

struct Item: Identifiable, Equatable, Codable {
    var id: String
    var Name: String
    var Price: String
    var QuantityAvailable: String
    var DonationBoxName: String
    var DonationBoxId: String
}

struct UpdateItem: Codable {
    var Name: String
    var Price: String
    var QuantityAvailable: Int
    var DonationBoxName: String
    var DonationBoxId: String
}

struct NewItem: Codable {
    var Name: String
    var Price: String
    var QuantityAvailable: Int
    var DonationBoxName: String
    var DonationBoxId: String
}


struct Transaction: Codable, Identifiable {
    var id = UUID().uuidString
    var Date: String = ""
    var Body: String = ""
    var `Type`: String = ""
}

struct DonationBox: Identifiable, Equatable, Hashable {
    var id: String
    var Name: String
    var TotalPrice: Double
    var Date: String
}

struct UpdateDonationBox: Codable {
    var Name: String
    var Date: String
    var TotalPrice: Double
}

struct NewDonationBox: Codable {
    var Name: String
    var Date: String
    var TotalPrice: Double = 0.00
}

