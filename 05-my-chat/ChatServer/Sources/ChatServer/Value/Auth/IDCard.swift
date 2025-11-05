//
//  IDCard.swift
//  ChatServer
//
//  Created by 김민우 on 11/4/25.
//
import Foundation


// MARK: Value
struct IDCard: Sendable, Hashable {
    // MARK: core
    let id = UUID()
    let email: String
    let password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    // MARK: operator
    func isMatched(_ email: String, _ password: String) -> Bool {
        self.email == email && self.password == password
    }
}
