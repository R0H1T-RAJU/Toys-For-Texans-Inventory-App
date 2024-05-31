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
                DonationBoxesView()
                    .tabItem {
                        Label("Donation Boxes", systemImage: "archivebox.fill")
                    }
//                Text("")
//                    .tabItem {
//                        Label("Requests", systemImage: "list.clipboard.fill")
//                    }
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
                try! await SuperItemsHandler.standard.getItems()
                try! await DonationBoxesHandler.standard.getBoxes()
                try! await TransactionsHandler.standard.getTransactions()
            }
    }
}

#Preview {
    MainPageHandler()
}
