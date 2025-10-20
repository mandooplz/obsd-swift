//
//  bookstoreApp.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//

import SwiftUI
import CoreData

@main
struct bookstoreApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
