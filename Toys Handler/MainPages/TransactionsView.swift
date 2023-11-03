//
//  TransactionsView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/1/23.
//

import SwiftUI

struct TransactionsView: View {
    @ObservedObject var transactionsHandler: TransactionsHandler = .standard
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(transactionsHandler.transactions, id: \.id) {transaction in
                    NavigationLink(destination: TransactionView(transaction: transaction))  
                    {
                        HStack {
                            Text(transaction.Type)
                            Spacer()
                            Text(String(transaction.Date))
                        }
                    }
                }
            }
            .navigationTitle(Text("Transaction History"))
            .refreshable {
                do {
                    transactionsHandler.transactions = try! await FirebaseFunctions().getTranscations()
                }
            }
        }
    }
}

#Preview {
    TransactionsView()
}
