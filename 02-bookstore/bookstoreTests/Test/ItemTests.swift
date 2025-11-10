//
//  ItemTests.swift
//  bookstore
//
//  Created by 김민우 on 10/20/25.
//
import Testing
@testable import bookstore


// MARK: Tests
@Suite("Item", .timeLimit(.minutes(1)))
struct ItemTests {
    struct Remove {
        let itemBoard: ItemBoard
        let item: Item
        init() async throws {
            self.itemBoard = await ItemBoard(itemBoxFlow: ItemBoxFlowMock())
            self.item = try await getItemForTest(itemBoard)
        }
        
        @Test func IsValidToFalse() async throws {
            // given
            try await #require(item.isValid == true)
            
            // when
            await item.remove()
            
            // then
            await #expect(item.isValid == false)
        }
        @Test func ItemBoard_removeItem() async throws {
            // given
            try await #require(itemBoard.items.contains { $0.id == item.id })
            
            // when
            await item.remove()
            
            // then
            let isItemExist = await itemBoard.items.contains { $0.id == item.id }
            #expect(isItemExist == false)
        }
    }
}


// MARK: Helpher
private func getItemForTest(_ itemBoard: ItemBoard) async throws -> Item {
    try await #require(itemBoard.items.isEmpty)
    
    await itemBoard.createItem()
    
    try await #require(itemBoard.items.count == 1)
    return await itemBoard.items.first!
}
