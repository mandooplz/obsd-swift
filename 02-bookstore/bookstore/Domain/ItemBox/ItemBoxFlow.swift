//
//  ItemBoxFlow.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import CoreData 


// MARK: Flow Interface
protocol ItemBoxFlowInterface: Sendable {
    @concurrent func getItemModels() async -> [ItemSnapshot]
    @concurrent func addItemModel() async
    @concurrent func deleteItemModel(_ snapshot: ItemSnapshot) async
}


// MARK: Flow
struct ItemBoxFlow: ItemBoxFlowInterface {
    @concurrent
    func getItemModels() async -> [ItemSnapshot] {
        let container = await PersistenceController.shared.container
        
        return await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let policy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
                context.mergePolicy = policy
                
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemModel.timestamp, ascending: true)]
                
                do {
                    let rows = try context.fetch(request)
                    let snaps: [ItemSnapshot] = rows.compactMap {
                        guard let id = $0.id, let timestamp = $0.timestamp else { return nil }
                        return ItemSnapshot(id: id, timestamp: timestamp)
                    }
                    continuation.resume(returning: snaps)
                } catch {
                    print("Background Fetch error: ", error)
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    @concurrent
    func addItemModel() async {
        let container = await PersistenceController.shared.container
        
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let policy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
                context.mergePolicy = policy
                
                let object = ItemModel(context: context)
                object.id = UUID()
                object.timestamp = Date()
                
                do {
                    try context.save()
                } catch {
                    print("Background save error: ", error)
                }
                
                continuation.resume()
            }
        }
    }
    
    @concurrent
    func deleteItemModel(_ snapshot: ItemSnapshot) async {
        let container = await PersistenceController.shared.container
        
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let policy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
                context.mergePolicy = policy
                
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", snapshot.id.uuidString)
                
                do {
                    if let target = try context.fetch(request).first {
                        context.delete(target)
                        try context.save()
                    }
                } catch {
                    print("Backgroun delete error: ", error)
                }
                
                continuation.resume()
            }
        }
    }
}
