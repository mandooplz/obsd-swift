//
//  Message.swift
//  ChatApp
//
//  Created by 김민우 on 11/4/25.
//
import Foundation


// MARK: value
struct Message: Sendable, Hashable, Codable {
    let id: UUID
    let senderEmail: String
    let content: String
    let createdAt: Date
    
    init(id: UUID = UUID(), senderEmail: String, content: String, createdAt: Date) {
        self.id = id
        self.senderEmail = senderEmail
        self.content = content
        self.createdAt = createdAt
    }
}
