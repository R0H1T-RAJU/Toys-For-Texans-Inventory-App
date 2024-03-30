//
//  ContentView.swift
//  Toys Handler
//
//  Created by Rohit Raju on 9/25/23.
//

import SwiftUI

struct Login: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
//                Image("tft-logo")
//                    .resizable()
//                    .frame(width: 200, height: 200)
                    
                    
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                TextField("Email", text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                SecureField("Psssword", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    Text("Login")
                        .frame(width: 300, height: 50)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
   
//                HStack {
//                    Text("Dont have an acoount?")
//                        .foregroundColor(.blue)
//                    NavigationLink(destination: Register(),
//                                   label: {
//                        Text("Register")
//                            .underline(true)
//                            .foregroundColor(.blue)
//                    })
//                }
//                .frame(width: 300, alignment: .leading)
            }
            .padding()
        }
    }
}

extension Login: AuthFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
    
}

#Preview {
    Login()
}
