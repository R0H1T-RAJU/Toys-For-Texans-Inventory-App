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
    let itemsCollectionName = "items"
    let transactionsCollectionName = "transactions"
    
    var itemsCollection: CollectionReference
    var transactionsCollection: CollectionReference
    
    init() {
        self.itemsCollection = Firestore.firestore().collection(itemsCollectionName)
        self.transactionsCollection = Firestore.firestore().collection(transactionsCollectionName)
    }
    
    func getItems() async throws -> [Item] {
        let snapshot = try await itemsCollection.getDocuments()
        print("data retrieved")
        return snapshot.documents.map{Item(id: $0.documentID, Name: $0.data()["Name"] as! String, Price: $0.data()["Price"] as! String, QuantityAvailable: $0.data()["QuantityAvailable"] as! Int, QuantityReserved: $0.data()["QuantityReserved"] as! Int, QuantityGiven: $0.data()["QuantityGiven"] as! Int)}
    }
    
    func addItem(item: NewItem) {
        do {
            try itemsCollection.document().setData(from: item)
            createTransaction(type: .add, newItem: item)
            print("item added")
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func updateItem(item: Item, index: Int) {
        let updatedVals = NewItem(Name: item.Name, Price: item.Price, QuantityAvailable: item.QuantityAvailable)
        do {
            try itemsCollection.document(item.id).setData(from: updatedVals)
            let itemsHandler: SuperItemsHandler = .standard
            createTransaction(type: .update, item: item, staticItem: itemsHandler.staticItems[index])
            itemsHandler.staticItems[index] = itemsHandler.items[index]
            print("item updated")
            
        } catch let error {
            print("Error updating document: \(error)")
        }
    }
    
    func deleteItem(item: Item) {
        itemsCollection.document(item.id).delete()
        createTransaction(type: .remove, item: item)
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
        case add
        case update
        case remove
    }
    
    func createTransaction(type: TransactionType, item: Item? = nil, staticItem: Item? = nil, newItem: NewItem? = nil) {
        let transactionRef = transactionsCollection.document("transactions")
        var transactionData: Transaction = Transaction()
        
        //Gets current date of transaction
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        let result = formatter.string(from: date)
        transactionData.Date = result
        
        switch type {
            //case when item is added
        case .add:
            transactionData.Type = "Item Added"
            let totalItemPrice = Double((Double(newItem!.Price) ?? 0) * Double(newItem!.QuantityAvailable))
            let totalPriceString =  String(format: "%.2f", totalItemPrice)
            transactionData.Body = "\(newItem!.Name) added with a quantity of \(newItem!.QuantityAvailable) at a price of $\(newItem!.Price) with a total cost of $\(totalPriceString)"
            //case when item is updated
        case .update:
            transactionData.Type = "Item Updated"
            if(!(item!.Name == staticItem!.Name)) {
                transactionData.Body += "\(staticItem!.Name) renamed to \(item!.Name)*"
            }
            if(!(item!.Price == staticItem!.Price)) {
                transactionData.Body += "Item price updated to \(item!.Price)*"
            }
            if(!(item!.QuantityAvailable == staticItem!.QuantityAvailable)) {
                transactionData.Body += "Item quantity changed from \(staticItem!.QuantityAvailable) to \(item!.QuantityAvailable)"
            }
            //case when item is removed
        case .remove:
            transactionData.Type = "Item Removed"
            transactionData.Body = "\(item!.Name) was removed"
        }
        transactionRef.updateData([
            "transactions": FieldValue.arrayUnion([["id":transactionData.id, "Date": transactionData.Date, "Body": transactionData.Body, "Type": transactionData.Type]])
        ])
    }
}
