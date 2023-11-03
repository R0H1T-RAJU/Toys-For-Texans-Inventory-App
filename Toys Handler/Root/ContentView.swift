//
//  ContentView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/1/23.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var viewModel = AuthViewModel() //for testing

    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainPageHandler()
            } else {
                Login()
            }
        }
//        .environmentObject(viewModel) //for testing
    }
}

#Preview {
    ContentView()
}
