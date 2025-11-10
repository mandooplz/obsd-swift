//
//  Item.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
internal final class Item: Sendable, Identifiable {
    // MARK: core
    private(set) var isValid: Bool = true
    init(owner: ItemBoard, sourceId: UUID, timestamp: Date) {
        self.owner = owner
        self.sourceId = sourceId
        self.timestamp = timestamp
    }
    
    
    // MARK: state
    internal nonisolated let id = UUID()
    internal nonisolated let owner: ItemBoard
    
    internal nonisolated let sourceId: UUID
    internal nonisolated let timestamp: Date
    internal var fomattedTimestamp: String {
        timestamp.formatted(.dateTime.year().month().day().hour().minute().second())
    }
    
    
    // MARK: action
    internal func remove() async {
        guard isValid else { return }
        
        // capture
        let itemBoxFlow = owner.itemBoxFlow
        
        // compute
        let snapshot = ItemSnapshot(id: sourceId, timestamp: self.timestamp)
        
        await itemBoxFlow.deleteItemModel(snapshot)

        // mutate
        self.owner.items.removeAll { $0.id == self.id }
        
        self.isValid = false
    }
}
