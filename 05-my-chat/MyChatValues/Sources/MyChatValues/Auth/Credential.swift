//
//  Credential.swift
//  ChatApp
//
//  Created by 김민우 on 11/4/25.
//
import Foundation


// MARK: Value
nonisolated public struct Credential: Sendable, Hashable, Codable {
    // MARK: core
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

