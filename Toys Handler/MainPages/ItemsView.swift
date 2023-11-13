//
//  ItemsView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 10/10/23.
//

import SwiftUI

struct ItemsView: View {
    @ObservedObject var itemsHandler: SuperItemsHandler = .standard
    
    @State private var searchTerm = ""
    var filteredItems: [Item] {
        searchTerm.isEmpty ? itemsHandler.items : itemsHandler.items.filter { $0.Name.contains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack {
            List {
//                CreatePopup()
                ForEach(filteredItems, id: \.id) {item in
                    NavigationLink(destination: ItemView(index: itemsHandler.items.firstIndex(of: item)!, currentDonationBoxId: item.DonationBoxId))
                    {
                        HStack {
                            Text(item.Name)
                            Spacer()
                            Text(String(item.QuantityAvailable))
                        }
                    }
                } .onDelete {indexSet in
                    let itemIndex = itemsHandler.items.firstIndex(of: filteredItems[indexSet.first!])
                    itemsHandler.removeItem(at: itemIndex!)
                }
            }
            .navigationTitle(Text("Inventory"))
            .toolbar{EditButton()}
            .searchable(text: $searchTerm)
            .refreshable {
                do {
                    itemsHandler.items = try! await FirebaseFunctions().getItems()
                }
            }
        }
    }

}

#Preview {
    ItemsView()
}
