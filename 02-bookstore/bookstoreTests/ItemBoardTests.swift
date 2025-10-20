//
//  ItemBoardTests.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Testing
@testable import bookstore


// MARK: Tests
@Suite("ItemBoard", .timeLimit(.minutes(1)))
struct ItemBoardTests {
    struct CreateItem {
        let itemBoard: ItemBoard
        init() async throws {
            self.itemBoard = await ItemBoard()
        }
        
        @Test func addItem() async throws {
            // given
            try await #require(itemBoard.items.isEmpty)
            
            // when
            await itemBoard.createItem()
            
            // then
            await #expect(itemBoard.items.count == 1)
        }
    }
}
