//
//  FillerPage.swift
//  Toys Handler
//
//  Created by Rohit Raju on 10/1/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
//        let user = User.MOCK_USER // for testing
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.nameOrOrg)
                                .font(.system(size: 21))
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            Text(user.email)
                                .font(.system(size: 17))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        Text("Sign Out")
                            .tint(.red)
                    }
                }
            }
        } else {
            Section("Account") {
                Button {
                    viewModel.signOut()
                } label: {
                    Text("Sign Out")
                        .tint(.red)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
