//
//  GameCardTests.swift
//  TicTacToe
//
//  Created by 김민우 on 7/30/25.
//
import Foundation
import Testing
@testable import TicTacToeMac




// MARK: Tests
@Suite("GameCard")
struct GameCardTests {
    struct Select {
        let tictactoeRef: TicTacToe
        let gameCardRef: GameCard
        let gameBoardRef: GameBoard
        init() async throws {
            self.tictactoeRef = await TicTacToe()
            self.gameCardRef = try await getGameCard(tictactoeRef)
            self.gameBoardRef = try #require(await gameCardRef.board.ref)
        }
        
        @Test func whenGameCardIsDeleted() async throws {
            // given
            try await #require(gameCardRef.id.isExist == true)
            
            await gameCardRef.setCallback {
                await gameCardRef.delete()
            }
            
            // when
            await gameCardRef.select()
            
            // then
            let issue = try #require(await gameCardRef.issue)
            #expect(issue.reason == "gameCardIsDeleted")
        }
        @Test func whenGameIsEnded() async throws {
            // given
            await MainActor.run {
                gameBoardRef.isEnd = true
            }
            
            // when
            await gameCardRef.select()
            
            // then
            let issue = try #require(await gameCardRef.issue)
            #expect(issue.reason == "gameIsEnd")
        }
        
        @Test func changeOwner() async throws {
            // given
            try await #require(gameBoardRef.isEnd == false)
            let currentPlayer = await gameBoardRef.currentPlayer
            
            try await #require(gameCardRef.owner == nil)
            
            // when
            await gameCardRef.select()
            
            // then
            try await #require(gameCardRef.issue == nil)
            
            await #expect(gameCardRef.owner == currentPlayer)
        }
        @Test func whenAlreadySelected() async throws {
            // given
            await gameCardRef.select()
            
            try await #require(gameCardRef.owner != nil)
            
            // when
            await gameCardRef.select()
            
            // then
            let issue = try #require(await gameCardRef.issue)
            #expect(issue.reason == "alreadySelected")
        }
        
        @Test func toggleCurrentPlayer() async throws {
            // given
            let currentPlayer = await gameBoardRef.currentPlayer
            
            // when
            await gameCardRef.select()
            
            // then
            await #expect(gameBoardRef.currentPlayer != currentPlayer)
        }
        
        @Test func whenXWin_012() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            
            try await #require(gameBoardRef.currentPlayer == .X)
            
            try await #require(gameBoardRef.XPositions.isEmpty)
            try await #require(gameBoardRef.OPositions.isEmpty)
            
            try await #require(gameBoardRef.result == nil)
            try await #require(gameBoardRef.isEnd == false)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_3.select()
            await gameCardRef_1.select()
            await gameCardRef_4.select()
            await gameCardRef_2.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_345() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_5 = try #require(await gameBoardRef.cards[5]?.ref)
            
            // when
            await gameCardRef_3.select()
            await gameCardRef_0.select()
            await gameCardRef_4.select()
            await gameCardRef_1.select()
            await gameCardRef_5.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_678() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            let gameCardRef_7 = try #require(await gameBoardRef.cards[7]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)
            
            // when
            await gameCardRef_6.select()
            await gameCardRef_0.select()
            await gameCardRef_7.select()
            await gameCardRef_1.select()
            await gameCardRef_8.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_036() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_1.select()
            await gameCardRef_3.select()
            await gameCardRef_4.select()
            await gameCardRef_6.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_147() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_7 = try #require(await gameBoardRef.cards[7]?.ref)
            
            // when
            await gameCardRef_1.select()
            await gameCardRef_0.select()
            await gameCardRef_4.select()
            await gameCardRef_3.select()
            await gameCardRef_7.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_258() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_5 = try #require(await gameBoardRef.cards[5]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)
            
            // when
            await gameCardRef_2.select()
            await gameCardRef_0.select()
            await gameCardRef_5.select()
            await gameCardRef_1.select()
            await gameCardRef_8.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_048() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_1.select()
            await gameCardRef_4.select()
            await gameCardRef_2.select()
            await gameCardRef_8.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        @Test func whenXWin_246() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            
            // when
            await gameCardRef_2.select()
            await gameCardRef_0.select()
            await gameCardRef_4.select()
            await gameCardRef_1.select()
            await gameCardRef_6.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.X))
        }
        
        @Test func whenOWin_012() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            
            // when
            await gameCardRef_3.select()
            await gameCardRef_0.select()
            await gameCardRef_4.select()
            await gameCardRef_1.select()
            await gameCardRef_6.select()
            await gameCardRef_2.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_345() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_5 = try #require(await gameBoardRef.cards[5]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_3.select()
            await gameCardRef_1.select()
            await gameCardRef_4.select()
            await gameCardRef_6.select()
            await gameCardRef_5.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_678() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            let gameCardRef_7 = try #require(await gameBoardRef.cards[7]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_6.select()
            await gameCardRef_1.select()
            await gameCardRef_7.select()
            await gameCardRef_3.select()
            await gameCardRef_8.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_036() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            
            // when
            await gameCardRef_1.select()
            await gameCardRef_0.select()
            await gameCardRef_2.select()
            await gameCardRef_3.select()
            await gameCardRef_4.select()
            await gameCardRef_6.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_147() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_5 = try #require(await gameBoardRef.cards[5]?.ref)
            let gameCardRef_7 = try #require(await gameBoardRef.cards[7]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_1.select()
            await gameCardRef_2.select()
            await gameCardRef_4.select()
            await gameCardRef_5.select()
            await gameCardRef_7.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_258() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_5 = try #require(await gameBoardRef.cards[5]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_2.select()
            await gameCardRef_1.select()
            await gameCardRef_5.select()
            await gameCardRef_3.select()
            await gameCardRef_8.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_048() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)
            
            // when
            await gameCardRef_1.select()
            await gameCardRef_0.select()
            await gameCardRef_2.select()
            await gameCardRef_4.select()
            await gameCardRef_3.select()
            await gameCardRef_8.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        @Test func whenOWin_246() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            
            // when
            await gameCardRef_0.select()
            await gameCardRef_2.select()
            await gameCardRef_1.select()
            await gameCardRef_4.select()
            await gameCardRef_3.select()
            await gameCardRef_6.select()
            
            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .win(.O))
        }
        
        @Test func whenDraw() async throws {
            // given
            let gameCardRef_0 = try #require(await gameBoardRef.cards[0]?.ref)
            let gameCardRef_1 = try #require(await gameBoardRef.cards[1]?.ref)
            let gameCardRef_2 = try #require(await gameBoardRef.cards[2]?.ref)
            let gameCardRef_3 = try #require(await gameBoardRef.cards[3]?.ref)
            let gameCardRef_4 = try #require(await gameBoardRef.cards[4]?.ref)
            let gameCardRef_5 = try #require(await gameBoardRef.cards[5]?.ref)
            let gameCardRef_6 = try #require(await gameBoardRef.cards[6]?.ref)
            let gameCardRef_7 = try #require(await gameBoardRef.cards[7]?.ref)
            let gameCardRef_8 = try #require(await gameBoardRef.cards[8]?.ref)

            // when
            await gameCardRef_0.select() // X
            await gameCardRef_1.select() // O
            await gameCardRef_2.select() // X
            await gameCardRef_4.select() // O
            await gameCardRef_3.select() // X
            await gameCardRef_5.select() // O
            await gameCardRef_7.select() // X
            await gameCardRef_6.select() // O
            await gameCardRef_8.select() // X

            // then
            await #expect(gameBoardRef.isEnd == true)
            await #expect(gameBoardRef.result == .draw)
        }
    }
}



// MARK: Helphers
private func getGameCard(_ tictactoeRef: TicTacToe,
                         position: Int = 1) async throws -> GameCard {
    // create GameBoard
    try await #require(tictactoeRef.boards.isEmpty)
    await tictactoeRef.createGame()
    try await #require(tictactoeRef.boards.count == 1)
    
    let gameBoardRef = try #require(await tictactoeRef.boards.first?.ref)
    
    // create GameCard
    await gameBoardRef.setUp()
    
    return try #require(await gameBoardRef.cards[position]?.ref)
}

