//
//  Item.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
internal final class Item: Sendable {
    // MARK: core
    init(owner: ItemBoard.ID, sourceId: UUID, timestamp: Date) {
        self.owner = owner
        self.sourceId = sourceId
        self.timestamp = timestamp
    }
    
    
    // MARK: state
    internal nonisolated let id = ID()
    internal nonisolated let owner: ItemBoard.ID
    
    internal nonisolated let sourceId: UUID
    internal nonisolated let timestamp: Date
    
    
    // MARK: action
    internal func remove() {
        // compute
        // Flow를 통해 외부 모델에서 ItemModel을 제거
        
        // mutate
        // 현재 시스템에서 Item을 제거
    }
    
    
    // MARK: value
    @MainActor
    internal struct ID: Sendable, Hashable {
        // MARK: core
        internal let rawValue = UUID()
        internal nonisolated init() { }
        
        // MARK: operator
        internal var isExist: Bool {
            fatalError()
        }
        internal var ref: Item? {
            fatalError()
        }
    }
}


// MARK: ObjectManager
@MainActor @Observable
fileprivate final class ItemManager: Sendable {
    // MARK: state
    static var container: [Item.ID: Item] = [:]
    static func register(_ object: Item) {
        self.container[object.id] = object
    }
    static func unregister(_ id: Item.ID) {
        self.container[id] = nil
    }
}
