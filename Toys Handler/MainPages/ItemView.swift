//
//  ItemView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 10/10/23.
//

import SwiftUI

struct ItemView: View {
    @ObservedObject var itemsHandler: SuperItemsHandler = .standard
    @State var index: Int
    
    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private let numberFormatter: NumberFormatter = NumberFormatter()

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
                        TextField("", value: $itemsHandler.items[index].QuantityAvailable, formatter: NumberFormatter())
                            .disabled(disableTextField)
                            .foregroundStyle(inputColor)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
//                    if(disableTextField) {
//                        HStack {
//                            Text("Quantity Available")
//                            Spacer()
//                            Text("\(itemsHandler.items[index].QuantityAvailable)")
//                                .foregroundStyle(Color.gray)
//                        }
//                    } else {
//                        Picker("Quantity Available", selection: $itemsHandler.items[index].QuantityAvailable) {
//                            ForEach(0..<100, id:\.self) {
//                                Text("\($0)")
//                            }
//                        }
//                        .tint(Color("TextColor"))
//                    }
                }
                
                Section(header: Text("Request Details")) {
                    HStack {
                        Text("Quantity Reserved")
                        Spacer()
                        Text("\(itemsHandler.items[index].QuantityReserved)")
                            .foregroundStyle(Color.gray)
                    }
                    HStack {
                        Text("Quantity Given")
                        Spacer()
                        Text("\(itemsHandler.items[index].QuantityGiven)")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
        }
        .onDisappear(perform: {
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
