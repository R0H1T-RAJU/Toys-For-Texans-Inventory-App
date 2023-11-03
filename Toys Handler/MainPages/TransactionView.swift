//
//  TransactionView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/1/23.
//

import SwiftUI

struct TransactionView: View {
    let transaction: Transaction
    
    var body: some View {
        NavigationStack {
            List {
                Text(transaction.Date)
                if transaction.Type == "Item Updated" {
                    let components = transaction.Body.split(separator: "*")
                    ForEach(components, id: \.self) {component in
                        Text(component)
                    }
                } else {
                    Text(transaction.Body)
                }
                
            }
            .navigationTitle(transaction.Type)
        }
    }
}

//#Preview {
//    TransactionView()
//}
