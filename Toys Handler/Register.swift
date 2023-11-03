//
//  Register.swift
//  Toys Handler
//
//  Created by Rohit Raju on 9/25/23.
//

import SwiftUI

struct Register: View {
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Register")
                    .font(.largeTitle)
                    .bold()
                TextField("Full Name/Organization Name", text: $name)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
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
                ZStack(alignment: .trailing) {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    if(!password.isEmpty && !confirmPassword.isEmpty) {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, nameOrOrg: name)
                    }
                } label: {
                    Text("Register")
                        .frame(width: 300, height: 50)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            }
            .padding()
        }
    }
}

extension Register: AuthFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && password == confirmPassword
        && !name.isEmpty
    }
}

#Preview {
    Register()
}
