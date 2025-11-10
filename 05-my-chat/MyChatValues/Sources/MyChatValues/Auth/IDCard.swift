//
//  IDCard.swift
//  ChatServer
//
//  Created by 김민우 on 11/4/25.
//
import Foundation


// MARK: Value
public struct IDCard: Sendable, Hashable {
    // MARK: core
    public let id = UUID()
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    // MARK: operator
    public func isMatched(_ email: String, _ password: String) -> Bool {
        self.email == email && self.password == password
    }
}
