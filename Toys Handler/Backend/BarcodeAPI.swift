//
//  ApiCalleer.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/1/23.
//

import Foundation

struct BarcodeAPI {
    func getAPI(barcodeString: String) async throws -> [String: String] {
        var itemVals = ["name": "", "price": ""]
        
        let apiKey = "?token=c2b5b966d81967ec5f9a"
        guard let url = URL(string: "https://api.barcodespider.com/v1/lookup" + apiKey + "&upc=" + barcodeString) else {return itemVals}
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let stores = json!["Stores"] as? [[String: Any]],
               let itemData = stores.first as? [String: String] {
                print("itemData \(itemData)")
                itemVals["name"] = itemData["title"]
                itemVals["price"] = itemData["price"]
            }
        } catch {
            print(error)
        }
        return itemVals
    }
}
