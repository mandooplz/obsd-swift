//
//  Credential.swift
//  ChatApp
//
//  Created by 김민우 on 11/4/25.
//
import Foundation


// MARK: Value
nonisolated struct Credential: Sendable, Hashable, Codable {
    let email: String
    let password: String
}

