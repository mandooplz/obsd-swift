//
//  ItemBoxFlow.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import CoreData


// MARK: Flows
struct ItemBoxFlow: Sendable {
    
    @concurrent
    static func getItemModels() async -> [ItemSnapshot] {
        let container = await PersistenceController.shared.container
        
        await container.performBackgroundTask { context in
            
        }
    }
    
    @concurrent
    static func addItemModel() async {
        fatalError()
    }
    
    @concurrent
    static func deleteItemModel(_ snapshot: ItemSnapshot) async {
        fatalError()
    }
}
