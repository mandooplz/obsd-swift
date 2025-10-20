//
//  ItemBoard.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
internal final class ItemBoard: Sendable {
    // MARK: core
    
    
    // MARK: state
    internal nonisolated let id: ID = ID()
    
    internal var items: [Item.ID] = []
    
    private(set) var itemQueue: [UUID: Ticket] = [:]
    internal func addTicket(_ ticket: Ticket) {
        self.itemQueue[ticket.id] = ticket
    }
    
    
    // MARK: action
    public func processTickets() {
        // mutate
    }
    
    public func cleanTickets() {
        // mutate
    }
    
    
    
    // MARK: value
    @MainActor
    internal struct ID: Sendable, Hashable {
        // MARK: core
        internal let rawValue: UUID = UUID()
        nonisolated init() { }
        
        internal var isExist: Bool {
            ItemBoardManager.container[self] != nil
        }
        internal var ref: ItemBoard? {
            ItemBoardManager.container[self]
        }
    }
    
    internal struct Ticket: Sendable, Hashable {
        // MARK: core
        internal let id: UUID
        internal let status: Status
        
        internal init() {
            self.init(id: UUID(), status: .unhandled)
        }
        private init(id: UUID, status: Status) {
            self.id = id
            self.status = status
        }
        
        
        // MARK: value
        internal enum Status {
            case unhandled
            case done
        }
    }
}


// MARK: ObjectManager
@MainActor @Observable
fileprivate final class ItemBoardManager: Sendable {
    // MARK: state
    static var container: [ItemBoard.ID: ItemBoard] = [:]
    static func register(_ object: ItemBoard) {
        container[object.id] = object
    }
}
