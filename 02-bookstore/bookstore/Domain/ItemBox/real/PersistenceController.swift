//
//  Persistence.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//

import CoreData


// MARK: actor
@globalActor
actor Database {
    static let shared = Database()
}


// MARK: Controller
@Database
struct PersistenceController {
    // MARK: core
    static let shared = PersistenceController(inMemory: true)

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "bookstore")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
