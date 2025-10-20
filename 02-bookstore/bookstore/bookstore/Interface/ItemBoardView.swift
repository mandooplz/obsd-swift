//
//  ContentView.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//

import SwiftUI
import CoreData

struct ItemBoardView: View {
    // MARK: viewmodel
    @State var itemBoardRef = ItemBoard()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemModel.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ItemModel>

    
    // MARK: view
    var body: some View {
        NavigationView {
            List {
                ForEach(itemBoardRef.items, id: \.rawValue) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                    
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            print("삭제합니다.")
                        } label: {
                            Label("삭제", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = ItemModel(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ItemBoardView()
}
