//
//  ContentView.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import SwiftUI


// MARK: View
struct ItemBoardView: View {
    // MARK: model
    @State var itemBoardRef = ItemBoard(mode: .real)
    
    
    // MARK: view
    var body: some View {
        NavigationStack {
            List(itemBoardRef.items) { item in
                NavigationLink {
                    ItemView(item)
                } label: {
                    ItemLabel(item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await item.remove() }
                    } label: {
                        Label("삭제", systemImage: "trash.fill")
                    }
                }
            }
            .navigationTitle(Text("Items"))
            .toolbar {
                ToolbarItem {
                    Button {
                        Task { await itemBoardRef.createItem() }
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }

                }
            }
        }.task {
            await itemBoardRef.fetchItems()
        }
    }
}


// MARK: Preview
#Preview {
    ItemBoardView()
}
