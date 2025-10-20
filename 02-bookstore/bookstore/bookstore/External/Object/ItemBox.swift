//
//  ItemBox.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import CoreData


// MARK: actor
@globalActor
internal actor Database {
    static var shared = Database()
}


// MARK: Object
@Database
internal final class ItemBox: Sendable {
    // MARK: core
    private let container = PersistenceController.shared.container
    
    
    // MARK: state
    internal func getItems() -> [ItemSnapshot] {
        fatalError()
    }
    internal func createItem() {
        fatalError()
    }
    internal func deleteItem(_ snapshot: ItemSnapshot) {
        fatalError()
    }
}
