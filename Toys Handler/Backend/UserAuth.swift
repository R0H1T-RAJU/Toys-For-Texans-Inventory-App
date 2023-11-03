//  UserAuth.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/1/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthFormProtocol {
    var formIsValid: Bool {get}
}

@MainActor
class AuthViewModel: ObservableObject {
    let usersCollectionName = "AppUsers"
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("Failed to login with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, nameOrOrg: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, nameOrOrg: nameOrOrg, email: email, type: "General")
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection(usersCollectionName).document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() //signs out user on backend
            self.userSession = nil  //wipes out user session and returns to login screeen
            self.currentUser = nil
        } catch {
            print("failed to sign out with \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let snapshot = try? await Firestore.firestore().collection(usersCollectionName).document(uid).getDocument() else {return}
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
}
