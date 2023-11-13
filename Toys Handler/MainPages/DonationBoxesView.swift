//
//  DonationBoxesView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/8/23.
//

import SwiftUI

struct DonationBoxesView: View {
    @ObservedObject var boxesHandler: DonationBoxesHandler = .standard
    @State var searchTerm = ""
    var filteredBoxes: [DonationBox] {
        searchTerm.isEmpty ? boxesHandler.donationBoxes : boxesHandler.donationBoxes.filter { $0.Name.contains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack {
            List {
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
            .toolbar{EditButton()}
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
