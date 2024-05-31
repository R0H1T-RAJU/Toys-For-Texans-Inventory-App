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
    let donationBox: DonationBox
    
    @State private var showActionSheet = false
    @State private var isShowingPopup = false
    @State private var isPresentingScanner = false
    
    @ObservedObject var itemsHandler: SuperItemsHandler = .standard
    @State var scannedCode: String?
    let firebaseFunctions = FirebaseFunctions()
    
    
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
                        let nameValidation = name.rangeOfCharacter(from: NSCharacterSet.letters)
                        if (nameValidation != nil) {
                            if quantity == "" {quantity = "1"}
                            if price == "" {price = "0.00"}
                            if (itemsHandler.items.contains{$0.Name.lowercased() == name.lowercased()} && itemsHandler.items.first{$0.Name == name}?.DonationBoxId == donationBox.id) {
                                let duplicateItem = itemsHandler.items.first{$0.Name == name}
                                firebaseFunctions.incrQuantityAvailable(id: duplicateItem!.id, amount: Int(quantity)!)
                            }
                            else {
                                let newItem = NewItem(Name: name, Price: price, QuantityAvailable: Int(quantity) ?? 1, DonationBoxName: donationBox.Name, DonationBoxId: donationBox.id)
                                firebaseFunctions.addItem(item: newItem)
                            }
                            SuperItemsHandler.standard.items = try! await firebaseFunctions.getItems()
                            SuperItemsHandler.standard.staticItems = SuperItemsHandler.standard.items
                        }
                        clearVariables()
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

//#Preview {
//    CreatePopup()
//}
