//
//  DonationBoxesView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/8/23.
//

import SwiftUI

struct DonationBoxesView: View {
    @ObservedObject var boxesHandler: DonationBoxesHandler = .standard
    
    var sortedBoxes: [DonationBox] {
        if sortTerm == .nameAscending {
            return boxesHandler.donationBoxes.sorted {sortBoxes($0.Name, $1.Name)}
        }
        if sortTerm == .nameDescending {
            return boxesHandler.donationBoxes.sorted {sortBoxes($1.Name, $0.Name)}
        }
        if sortTerm == .price {
            return boxesHandler.donationBoxes.sorted {$0.TotalPrice > $1.TotalPrice}
        }
        if sortTerm == .dateRecieved {
            return boxesHandler.donationBoxes.sorted {$1.Date < $0.Date}
        }
        return []
    }
    
    @State var searchTerm = ""
    var filteredBoxes: [DonationBox] {
        searchTerm.isEmpty ? sortedBoxes : sortedBoxes.filter { $0.Name.lowercased().contains(searchTerm.lowercased()) }
    }
    enum Sort: String, CaseIterable, Identifiable {
        case nameAscending, nameDescending, price, dateRecieved
        var id: Self { self }
    }
    @State var sortTerm: Sort = .nameAscending

    var body: some View {
        NavigationStack {
            List() {
                CreateBox()
                ForEach(filteredBoxes, id: \.id) {donationBox in
                    NavigationLink(destination: DonationBoxView(index: boxesHandler.donationBoxes.firstIndex(of: donationBox)!)) {
                        HStack {
                            Text(donationBox.Name)
                            Spacer()
                            Text(String(format: "$%.2f", donationBox.TotalPrice))
                        }
                    }
                }
                .onDelete {indexSet in
                    let itemIndex = boxesHandler.donationBoxes.firstIndex(of: filteredBoxes[indexSet.first!])
                    boxesHandler.removeBox(at: itemIndex!)
                }
                
            }
            .navigationTitle("Donation Boxes")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {EditButton()}
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("", selection: $sortTerm) {
                            Text("Name Ascending").tag(Sort.nameAscending)
                            Text("Name Descending").tag(Sort.nameDescending)
                            Text("Total Price").tag(Sort.price)
                            Text("Date Recieved").tag(Sort.dateRecieved)
                        }
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            })
            .searchable(text: $searchTerm)
            .refreshable {
                do {
                    try! await boxesHandler.getBoxes()
                }
            }
        }
    }
}
#Preview {
    DonationBoxesView()
}
