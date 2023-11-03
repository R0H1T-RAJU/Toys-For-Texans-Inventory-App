//
//  User.swift
//  Toys Handler
//
//  Created by Rohit Raju on 11/1/23.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let nameOrOrg: String
    let email: String
    let type: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: nameOrOrg) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: UUID().uuidString, nameOrOrg: "Rohit Raju", email: "rohitbraju@gmail.com", type: "General")
}
