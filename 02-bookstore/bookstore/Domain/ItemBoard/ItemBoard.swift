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
    init(mode: SystemMode = .test) {
        // mode에 따라 서로 다른 ItemBoard를 사용
        switch mode {
        case .test:
            self.itemBoxFlow = ItemBoxFlowMock()
        case .real:
            self.itemBoxFlow = ItemBoxFlow()
        }
    }
    
    
    // MARK: state
    internal nonisolated let id = UUID()
    internal nonisolated let itemBoxFlow: any ItemBoxFlowInterface
    
    internal var items: [Item] = []
    
    
    // MARK: action
    public func createItem() async {
        // compute
        await itemBoxFlow.addItemModel()
        let itemSnapshots = await itemBoxFlow.getItemModels()
        
        // mutate
        let newItems = itemSnapshots
            .map { Item(owner: self, sourceId: $0.id, timestamp: $0.timestamp) }
        
        self.items = newItems
    }
    
    public func fetchItems() async {
        // compute
        let itemSnapshots = await itemBoxFlow.getItemModels()
        
        // mutate
        let newItems = itemSnapshots
            .map { Item(owner: self, sourceId: $0.id, timestamp: $0.timestamp) }
        
        self.items = newItems
    }
    
    
    // MARK: value
    internal struct Ticket: Sendable, Hashable {
        // MARK: core
        internal let id: UUID = UUID()
        nonisolated init() { }
    }
}
