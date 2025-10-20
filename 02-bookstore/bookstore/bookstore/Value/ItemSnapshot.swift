//
//  ItemSnapshot.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Foundation


// MARK: value
internal struct ItemSnapshot: Sendable, Hashable {
    internal let id: UUID
    internal let timestamp: Date
    
    init(id: UUID, timestamp: Date) {
        self.id = id
        self.timestamp = timestamp
    }
}

