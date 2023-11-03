//
//  CreatePopup.swift
//  Toys Handler
//
//  Created by Rohit Raju on 10/11/23.
//

import SwiftUI
import CodeScanner
import CodeScanner


struct CreatePopup: View {
    @State var name = ""
    @State var price = ""
    @State var quantity = ""    
    
    @State private var showActionSheet = false
    @State private var isShowingPopup = false
    @State private var isPresentingScanner = false
    
    @State var scannedCode: String?
    
    
    var body: some View {
        HStack {
            Button {
                showActionSheet = true
            } label: {
                Text("Add Item")
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Add Item From"),
                            buttons: [
                                .cancel(),
                                .default(
                                    Text("Add Manually"),
                                    action: {isShowingPopup = true}
                                ),
                                .default(
                                    Text("Scan Item"),
                                    action: {isPresentingScanner = true}
                                )
                            ]
                )
            }
            .sheet(isPresented: $isPresentingScanner, onDismiss: {isShowingPopup = true}) {
                CodeScannerView(codeTypes: [.code128, .code39, .upce, .code93, .ean13]) { response in
                    if case let .success(result) = response {
                        scannedCode = result.string
                        let barcodeAPI: BarcodeAPI = BarcodeAPI()
                        Task {
                            let itemData =  try await barcodeAPI.getAPI(barcodeString: scannedCode!)
                            name = itemData["name"] ?? ""
                            price = itemData["price"] ??  ""
                        }
                        isPresentingScanner = false
                    }
                }
            }
            .alert("Create Item", isPresented: $isShowingPopup) {
                TextField("Item Name", text: $name)
                    .foregroundStyle(Color("TextColor"))
                TextField("Item Price", text: $price)
                    .foregroundStyle(Color("TextColor"))
                    .keyboardType(.decimalPad)
                TextField("Item Quantity", text: $quantity)
                    .foregroundStyle(Color("TextColor"))
                    .keyboardType(.numberPad)
                Button("Cancel", role: .destructive) {clearVariables()}
                
                Button("Create", role: .cancel) {
                    Task {
                        if price == "" {price = "0.00"}
                        if quantity == "" {quantity = "1"}
                        let newItem = NewItem(Name: name, Price: price, QuantityAvailable: Int(quantity) ?? 0)
                        clearVariables()
                        FirebaseFunctions().addItem(item: newItem)
                        SuperItemsHandler.standard.items = try! await FirebaseFunctions().getItems()
                        SuperItemsHandler.standard.staticItems = SuperItemsHandler.standard.items
                    }
                }
            }
        }
    }
    
    func clearVariables() {
        name = ""
        price = ""
        quantity = ""
    }
}

#Preview {
    CreatePopup()
}
