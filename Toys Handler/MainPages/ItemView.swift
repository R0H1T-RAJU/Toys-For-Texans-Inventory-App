//
//  ItemView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 10/10/23.
//

import SwiftUI

struct ItemView: View {
    @ObservedObject var itemsHandler: SuperItemsHandler = .standard
    @ObservedObject var boxesHandler: DonationBoxesHandler = .standard
    
    @State var index: Int
    let currentDonationBoxId: String
    
    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Item Details")) {
                    HStack {
                        Text("Item Price")
                        TextField("", text: $itemsHandler.items[index].Price)
                            .disabled(disableTextField)
                            .foregroundStyle(inputColor)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Quantity Available")
                        TextField("", text: $itemsHandler.items[index].QuantityAvailable)
                            .disabled(disableTextField)
                            .foregroundStyle(inputColor)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if(disableTextField) {
                        HStack {
                            Text("Donation Box")
                            Spacer()
                            Text("\(itemsHandler.items[index].DonationBoxName)")
                                .foregroundStyle(Color.gray)
                        }
                    } else {
                        Picker("Donation Box", selection: $itemsHandler.items[index].DonationBoxId) {
                            ForEach(boxesHandler.donationBoxes, id:\.id) {donationBox in
                                Text("\(donationBox.Name)")
                            }
                        }
                        .tint(Color("TextColor"))
                        .onChange(of: itemsHandler.items[index].DonationBoxId) {newId in
                            let item = itemsHandler.items[index]
                            let totalPrice = Double(item.QuantityAvailable)! * Double(item.Price)!
                            FirebaseFunctions().incrBoxTotalPrice(boxId: currentDonationBoxId, price: -totalPrice)
                            FirebaseFunctions().incrBoxTotalPrice(boxId: newId, price: totalPrice)
                            itemsHandler.items[index].DonationBoxName = boxesHandler.donationBoxes.first{$0.id == newId}!.Name
                        }
                    }
                }
            }
        }
        .onDisappear(perform: {
            if(itemsHandler.items[index].QuantityAvailable == "") {itemsHandler.items[index].QuantityAvailable = "0"}
            if !(itemsHandler.items[index] == itemsHandler.staticItems[index]) {
                itemsHandler.updateItem(index: index)
            }
        })
        .navigationTitle($itemsHandler.items[index].Name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {EditButton()}
    }
    
    var inputColor: Color {
        return disableTextField ? Color.gray : Color("TextColor")
    }
    
    var disableTextField: Bool {
        return !(editMode?.wrappedValue.isEditing)!
    }
}

//#Preview {
//    ItemView()
//}
