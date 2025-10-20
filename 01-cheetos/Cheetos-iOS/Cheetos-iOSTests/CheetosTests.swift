//
//  CheetosTests.swift
//  Cheetos
//
//  Created by 김민우 on 8/28/25.
//
import Testing
import Foundation
import Cheetos_iOS


// MARK: tests
@Suite("Cheetos")
struct CheetosTests {
    struct NewFortune {
        let cheetosRef: Cheetos
        init() async {
            self.cheetosRef = await Cheetos()
        }
        
        @Test func addFortune() async throws {
            // given
            try await #require(cheetosRef.messages.isEmpty)
            
            // when
            await cheetosRef.newFortune()
            
            // then
            try await #require(cheetosRef.messages.count == 1)
            
            let message = try #require(await cheetosRef.messages.first)
            #expect(message is Fortune.ID)
        }
        @Test func createFortune() async throws {
            // given
            try await #require(cheetosRef.messages.isEmpty)
            
            // when
            await cheetosRef.newFortune()
            
            // then
            let message = try #require(await cheetosRef.messages.first as? Fortune.ID)
            await #expect(message.isExist == true)
        }
    }
    
    struct CreateMyMessage {
        let cheetosRef: Cheetos
        init() async {
            self.cheetosRef = await Cheetos()
        }
        
        @Test func addMyMessage() async throws {
            // given
            try await #require(cheetosRef.messages.isEmpty)
            
            // when
            await cheetosRef.createMyMessage()
            
            // then
            try await #require(cheetosRef.messages.count == 1)
            
            let message = try #require(await cheetosRef.messages.first)
            #expect(message is MyMessage.ID)
        }
        @Test func createFortune() async throws {
            // given
            try await #require(cheetosRef.messages.isEmpty)
            
            // when
            await cheetosRef.createMyMessage()
            
            // then
            let message = try #require(await cheetosRef.messages.first as? MyMessage.ID)
            await #expect(message.isExist == true)
        }
    }
}
