//
//  NewMsgTicket.swift
//  ChatServer
//
//  Created by 김민우 on 11/4/25.
//
import Foundation


// MARK: Value
nonisolated struct NewMsgTicket: Sendable, Hashable, Codable {
    // MARK: core
    let id: UUID
    let client: UUID
    let credential: Credential
    let content: String
    
    init(id: UUID = UUID(), client: UUID, credential: Credential, content: String) {
        self.id = id
        self.client = client
        self.credential = credential
        self.content = content
    }
}
