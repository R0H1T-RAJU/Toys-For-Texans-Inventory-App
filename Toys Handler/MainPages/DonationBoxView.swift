//
//  DonationBoxView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/8/23.
//

import SwiftUI

struct DonationBoxView: View {
    @ObservedObject var boxesHandler: DonationBoxesHandler = .standard
    @ObservedObject var itemsHandler: SuperItemsHandler = .standard
    @State var index: Int
    var filteredItems: [Item] { itemsHandler.items.filter{$0.DonationBoxId == boxesHandler.donationBoxes[index].id} }
    
    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Box Details")) {
                    HStack {
                        Text("Date Recieved")
                        Spacer()
                        TextField("", text: $boxesHandler.donationBoxes[index].Date)
                            .disabled(disableTextField)
                            .foregroundStyle(inputColor)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Total Price")
                        Spacer()
                        Text(String(format: "$%.2f", boxesHandler.donationBoxes[index].TotalPrice))
                            .foregroundStyle(.gray)
                    }
                }
                
                Section(header: Text("Items")) {
                    CreatePopup(donationBox: boxesHandler.donationBoxes[index])
                    ForEach(filteredItems, id:\.id) {item in
                        NavigationLink(destination: ItemView(index: itemsHandler.items.firstIndex(of: item)!, currentDonationBoxId: item.DonationBoxId))
                        {
                            HStack {
                                Text(item.Name)
                                Spacer()
                                Text(String(item.QuantityAvailable))
                            }
                        }
                    }
                    .onDelete {indexSet in
                        let itemIndex = itemsHandler.items.firstIndex(of: filteredItems[indexSet.first!])
                        itemsHandler.removeItem(at: itemIndex!)
                    }
                }
            }
        }
        .navigationTitle($boxesHandler.donationBoxes[index].Name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{EditButton()}
        .onDisappear() {
            if !(boxesHandler.donationBoxes[index] == boxesHandler.staticDonationBoxes[index]) {
                print("donation Box updated")
                boxesHandler.updateDonationBox(index: index)
            }
        }
    }
    
    var inputColor: Color {
        return disableTextField ? Color.gray : Color("TextColor")
    }
    
    var disableTextField: Bool {
        return !(editMode?.wrappedValue.isEditing)!
    }
}

//#Preview {
//    DonationBoxView()
//}
