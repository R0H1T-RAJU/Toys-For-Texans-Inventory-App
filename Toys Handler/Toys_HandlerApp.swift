//
//  Toys_HandlerApp.swift
//  Toys Handler
//
//  Created by Rohit Raju on 9/25/23.
//

import SwiftUI

@main
struct Toys_HandlerApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
