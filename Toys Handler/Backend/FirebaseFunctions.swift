//
//  FirebaseFunctions.swift
//  Toys Handler
//
//  Created by Rohit Raju on 9/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirebaseFunctions {
    let db = Firestore.firestore()
    let itemsCollectionName = "items"
    let transactionsCollectionName = "transactions"
    let donationBoxesCollectionName = "donationBoxes"
    
    var itemsCollection: CollectionReference
    var transactionsCollection: CollectionReference
    var donationBoxesCollection: CollectionReference
    
    init() {
        self.itemsCollection = db.collection(itemsCollectionName)
        self.transactionsCollection = db.collection(transactionsCollectionName)
        self.donationBoxesCollection = db.collection(donationBoxesCollectionName)
    }
    
    func incrQuantityAvailable(id: String, amount: Int) {
        let docRef = itemsCollection.document(id)
        docRef.updateData([
            "QuantityAvailable": FieldValue.increment(Int64(amount))
        ])
    }
    
    func getItems() async throws -> [Item] {
        let snapshot = try await itemsCollection.getDocuments()
        print("retrieved items")
        return snapshot.documents.map{Item(id: $0.documentID, Name: $0.data()["Name"] as! String, Price: $0.data()["Price"] as! String, QuantityAvailable: String($0.data()["QuantityAvailable"] as! Int), DonationBoxName: $0.data()["DonationBoxName"] as! String, DonationBoxId: $0.data()["DonationBoxId"] as! String)}
    }
    
    func addItem(item: NewItem) {
        do {
            try itemsCollection.document().setData(from: item)
            createTransaction(type: .addItem, newItem: item)
            let totalPrice: Double = Double(item.Price)! * Double(item.QuantityAvailable)
            incrBoxTotalPrice(boxId: item.DonationBoxId, price: totalPrice)
            print("item added")
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func updateItem(item: Item, staticItem: Item, index: Int) {
        let updateItem = UpdateItem(Name: item.Name, Price: item.Price, QuantityAvailable: Int(item.QuantityAvailable)!, DonationBoxName: item.DonationBoxName, DonationBoxId: item.DonationBoxId)
        do {
            try itemsCollection.document(item.id).setData(from: updateItem)
            let itemsHandler: SuperItemsHandler = .standard
            if(item.QuantityAvailable != staticItem.QuantityAvailable || item.Price != staticItem.Price) {
                let oldTotalPrice = Double(staticItem.QuantityAvailable)! * Double(staticItem.Price)!
                let newTotalPrice = Double(item.QuantityAvailable)! * Double(item.Price)!
                incrBoxTotalPrice(boxId: item.DonationBoxId, price: (newTotalPrice - oldTotalPrice))
            }
            createTransaction(type: .updateItem, item: item, staticItem: itemsHandler.staticItems[index])
            print("item updated")
            
        } catch let error {
            print("Error updating document: \(error)")
        }
    }
    
    func deleteItem(item: Item) {
        itemsCollection.document(item.id).delete()
        createTransaction(type: .removeItem, item: item)
        let totalPrice: Double = Double(item.Price)! * Double(item.QuantityAvailable)!
        incrBoxTotalPrice(boxId: item.DonationBoxId, price: -totalPrice)
        print("item deleted")
    }
    
    func getTranscations() async throws -> [Transaction] {
        var returnTransactions: [[String: String]] = []
        let document = try await transactionsCollection.document("transactions").getDocument()
        if document.data() != nil {
            guard let firebaseTransactions = document.data()!["transactions"] as? [[String : String]] else {
                return []
            }
            returnTransactions = firebaseTransactions
            print("retrieved transactions")
        } else {
            print("Error retrieving transactions")
        }
        return returnTransactions.map {Transaction(id: $0["id"]!, Date: $0["Date"]!, Body: $0["Body"]!, Type: $0["Type"]!)}.reversed()
    }
    
    enum TransactionType {
        case addItem
        case updateItem
        case removeItem
        case addDonationBox
        case updateDonationBox
        case removeDonationBox
    }
    
    func createTransaction(type: TransactionType, item: Item? = nil, staticItem: Item? = nil, newItem: NewItem? = nil, donationBox: DonationBox? = nil, staticDonationBox: DonationBox? = nil, newDonationBox: NewDonationBox? = nil) {
        let transactionRef = transactionsCollection.document("transactions")
        var transactionData: Transaction = Transaction()
        
        //Gets current date of transaction
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        let result = formatter.string(from: date)
        transactionData.Date = result
        
        switch type {
        //ITEM TRANSACTIONS
        case .addItem:
            transactionData.Type = "Item Added"
            let totalItemPrice = Double((Double(newItem!.Price) ?? 0) * Double(newItem!.QuantityAvailable))
            let totalPriceString =  String(format: "%.2f", totalItemPrice)
            transactionData.Body = "\(newItem!.Name) added in donation box \(newItem!.DonationBoxName) with a quantity of \(newItem!.QuantityAvailable) at a price of $\(newItem!.Price) with a total cost of $\(totalPriceString)"
        case .updateItem:
            transactionData.Type = "Item Updated"
            if(!(item!.Name == staticItem!.Name)) {
                transactionData.Body += "\(staticItem!.Name) renamed to \(item!.Name)*"
            }
            if(!(item!.Price == staticItem!.Price)) {
                transactionData.Body += "Item price updated to \(item!.Price)*"
            }
            if(!(item!.QuantityAvailable == staticItem!.QuantityAvailable)) {
                transactionData.Body += "Item quantity changed from \(staticItem!.QuantityAvailable) to \(item!.QuantityAvailable)*"
            }
            if(!(item!.DonationBoxId == staticItem!.DonationBoxId)) {
                transactionData.Body += "Item moved from \(staticItem!.DonationBoxName) to \(item!.DonationBoxName)"
            }
        case .removeItem:
            transactionData.Type = "Item Removed"
            transactionData.Body = "\(item!.Name) was removed"
        //DONATION BOX TRANSACTIONS
        case .addDonationBox:
            transactionData.Type = "Donation Box Created"
            transactionData.Body = "Donation Box: \(newDonationBox!.Name) was created and was recieved on \(newDonationBox!.Date)"
        case .updateDonationBox:
            transactionData.Type = "Donation Box Updated"
            if(donationBox!.Name != staticDonationBox!.Name) {
                transactionData.Body += "\(staticDonationBox!.Name) renamed to \(donationBox!.Name)*"
            }
            if(donationBox!.Date != staticDonationBox!.Name) {
                transactionData.Body += "Date recieved changed to \(donationBox!.Date)"
            }
        case .removeDonationBox:
            transactionData.Type = "Donation Box Removed"
            transactionData.Body = "Donation Box: \(donationBox!.Name) was removed"
        }
        transactionRef.updateData([
            "transactions": FieldValue.arrayUnion([["id":transactionData.id, "Date": transactionData.Date, "Body": transactionData.Body, "Type": transactionData.Type]])
        ])
    }
    
    func getDonationBoxes() async throws -> [DonationBox] {
        let snapshot = try await donationBoxesCollection.getDocuments()
        print("retrieved donation boxes")
        return snapshot.documents.map{DonationBox(id: $0.documentID, Name: $0.data()["Name"] as! String, TotalPrice: $0.data()["TotalPrice"] as! Double, Date: $0.data()["Date"] as! String)}
    }
    
    func incrBoxTotalPrice(boxId: String, price: Double) {
        donationBoxesCollection.document(boxId).updateData([
            "TotalPrice": FieldValue.increment(price)
        ])
        let boxesHandler : DonationBoxesHandler = .standard
        Task {
            try! await boxesHandler.getBoxes()
        }
    }
    
    func createDonationBox(donationBox: NewDonationBox) {
        do {
            try donationBoxesCollection.document().setData(from: donationBox)
            createTransaction(type: .addDonationBox, newDonationBox: donationBox)
            print("box created")
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func updateDonationBox(donationBox: DonationBox, staticDonationBox: DonationBox, index: Int) {
        let batch = db.batch()
        let itemsHandler: SuperItemsHandler = .standard
        let updateDontionBox = UpdateDonationBox(Name: donationBox.Name, Date: donationBox.Date, TotalPrice: donationBox.TotalPrice)
        do {
            try batch.setData(from: updateDontionBox, forDocument: donationBoxesCollection.document(donationBox.id))
            let updateItems = itemsHandler.items.filter{$0.DonationBoxId == donationBox.id}
            if (donationBox.Name != staticDonationBox.Name) {
                for item in updateItems {
                    batch.updateData(["DonationBoxName": donationBox.Name], forDocument: itemsCollection.document(item.id))
                    let index = itemsHandler.items.firstIndex(of: item)!
                    itemsHandler.items[index].DonationBoxName = donationBox.Name
                }
            }
            let boxesHandler: DonationBoxesHandler = .standard
            batch.commit()
            createTransaction(type: .updateDonationBox, donationBox: donationBox, staticDonationBox: boxesHandler.staticDonationBoxes[index])
            print("box updated")
        } catch let error {
            print(error)
        }
    }
    
    func deleteDonationBox(donationBox: DonationBox) {
        let batch = db.batch()
        batch.deleteDocument(donationBoxesCollection.document(donationBox.id))
        let deleteItems = SuperItemsHandler.standard.items.filter{$0.DonationBoxId == donationBox.id}
        for deleteItem in deleteItems {
            batch.deleteDocument(itemsCollection.document(deleteItem.id))
        }
        batch.commit()
        createTransaction(type: .removeDonationBox, donationBox: donationBox)
        print("box removed")
    }
}
