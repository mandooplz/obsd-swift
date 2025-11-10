//
//  ItemBoxFlowMock.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Foundation


// MARK: Flow
struct ItemBoxFlowMock: ItemBoxFlowInterface {
    private let storage: Storage
    
    init(initialSnapshots: [ItemSnapshot] = []) {
        self.storage = Storage(snapshots: initialSnapshots)
    }
    
    @concurrent
    func getItemModels() async -> [ItemSnapshot] {
        await storage.list()
    }
    
    @concurrent
    func addItemModel() async {
        await storage.insert()
    }
    
    @concurrent
    func deleteItemModel(_ snapshot: ItemSnapshot) async {
        await storage.remove(id: snapshot.id)
    }
}


// MARK: Storage
private actor Storage {
    private var snapshots: [ItemSnapshot]
    
    init(snapshots: [ItemSnapshot]) {
        self.snapshots = snapshots
    }
    
    func list() -> [ItemSnapshot] {
        snapshots.sorted { $0.timestamp < $1.timestamp }
    }
    
    func insert() {
        let newSnapshot = ItemSnapshot(id: UUID(), timestamp: Date())
        snapshots.append(newSnapshot)
    }
    
    func remove(id: UUID) {
        snapshots.removeAll { $0.id == id }
    }
}
