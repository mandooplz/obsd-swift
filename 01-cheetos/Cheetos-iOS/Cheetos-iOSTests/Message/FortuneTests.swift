//
//  FortuneTests.swift
//  Cheetos
//
//  Created by 김민우 on 8/28/25.
//
import Testing
import Foundation
import Cheetos_iOS


// MARK: Tests
@Suite("Fortune")
struct FortuneTests {
    struct Fetch {
        let cheetosRef: Cheetos
        let fortuneRef: Fortune
        init() async throws {
            self.cheetosRef = await Cheetos()
            self.fortuneRef = try await cheetosRef.getFortuneForTest()
        }
        
        @Test func setIsLoadingFalse() async throws {
            // given
            try await #require(fortuneRef.isLoading == true)
            
            // when
            await fortuneRef.fetch()
            
            // then
            await #expect(fortuneRef.isLoading == false)
        }
        @Test func setContent() async throws {
            // given
            try await #require(fortuneRef.content == nil)
            
            // when
            await fortuneRef.fetch()
            
            // then
            await #expect(fortuneRef.content != nil)
        }
        @Test func setCreatedAt() async throws {
            // given
            try await #require(fortuneRef.createdAt == nil)
            
            // when
            await fortuneRef.fetch()
            
            // then
            await #expect(fortuneRef.createdAt != nil)
        }
        
        @Test func whenAlreadyFetched() async throws {
            // given
            await fortuneRef.fetch()
            
            let content = try #require(await fortuneRef.content)
            let createdAt = try #require(await fortuneRef.createdAt)
            
            try await #require(fortuneRef.error == nil)
            try await #require(fortuneRef.isLoading == false)
            
            // when
            await fortuneRef.fetch()
            
            // then
            await #expect(fortuneRef.error == .alreadyFetched)
            await #expect(fortuneRef.isLoading == false)
            await #expect(fortuneRef.content == content)
            await #expect(fortuneRef.createdAt == createdAt)
        }
    }
}


// MARK: Helphers
fileprivate extension Cheetos {
    func getFortuneForTest() async throws -> Fortune {
        // createFortune
        try #require(self.messages.isEmpty)
        
        await self.newFortune()
        
        let fortune = try #require(messages.first as? Fortune.ID)
        return try #require(await fortune.ref)
    }
}
