//
//  CreateBox.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/10/23.
//

import SwiftUI

struct CreateBox: View {
    @State var showPopup = false
    @State var name = ""
    @State var date = ""
    let firebaseFunctions = FirebaseFunctions()
    
    @ObservedObject var boxesHandler: DonationBoxesHandler = .standard
    
    var body: some View {
        Button {
            showPopup = true
        } label: {
            Text("Create Box")
        }
        .alert("Create Box", isPresented: $showPopup) {
            TextField("Box Name", text: $name)
                .foregroundStyle(Color("TextColor"))
            TextField("Date Recieved", text: $date)
                .foregroundStyle(Color("TextColor"))
                .keyboardType(.numbersAndPunctuation)
            Button("Cancel", role: .destructive) {clearVariables()}
            Button("Create", role: .cancel) {
                Task {
                    firebaseFunctions.createDonationBox(donationBox: NewDonationBox(Name: name, Date: date))
                    boxesHandler.donationBoxes = try! await firebaseFunctions.getDonationBoxes()
                    boxesHandler.staticDonationBoxes = boxesHandler.donationBoxes
                    clearVariables()
                }
            }
        }
    }
    
    func clearVariables() {
        name = ""
        date = ""
    }
}

#Preview {
    CreateBox()
}

