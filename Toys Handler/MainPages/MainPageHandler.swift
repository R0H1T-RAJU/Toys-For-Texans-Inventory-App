//
//  MainPage.swift
//  Toys Handler
//
//  Created by Rohit Raju on 9/27/23.
//

import SwiftUI

struct MainPageHandler: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color(.gray).opacity(0.1))
    }
    
    var body: some View {
        NavigationView {
            TabView {
                ItemsView()
                    .tabItem {
                        Label("Inventory", systemImage: "house.fill")
                    }
                TransactionsView()
                    .tabItem {
                        Label("Transactions", systemImage: "chart.bar.doc.horizontal.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Account", systemImage: "person.circle.fill")
                    }
            }
        } .navigationBarHidden(true)
            .task {
                let itemList = try! await FirebaseFunctions().getItems()
                TransactionsHandler.standard.transactions = try! await FirebaseFunctions().getTranscations()
                SuperItemsHandler.standard.items = itemList
                SuperItemsHandler.standard.staticItems = itemList
            }
    }
}

#Preview {
    MainPageHandler()
}
