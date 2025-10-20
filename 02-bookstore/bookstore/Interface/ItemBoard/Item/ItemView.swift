//
//  ItemView.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import SwiftUI


// MARK: Label
struct ItemLabel: View {
    // MARK: model
    let item: Item
    init(_ item: Item) {
        self.item = item
    }
    
    
    // MARK: body
    var body: some View {
        Text(item.fomattedTimestamp)
    }
}


// MARK: View
struct ItemView: View {
    // MARK: model
    let item: Item
    init(_ item: Item) {
        self.item = item
    }
    
    
    // MARK: body
    var body: some View {
        VStack {
            Text("Just Item View")
            Text(item.fomattedTimestamp)
        }
    }
}
