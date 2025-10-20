//
//  ItemView.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import SwiftUI


// MARK: View
struct ItemView: View {
    // MARK: model
    let itemRef: Item
    init(_ itemRef: Item) {
        self.itemRef = itemRef
    }
    
    
    // MARK: body
    var body: some View {
        Text("ItemView입니다.")
    }
}
