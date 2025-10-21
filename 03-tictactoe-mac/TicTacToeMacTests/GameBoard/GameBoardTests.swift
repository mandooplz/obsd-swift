//
//  GameBoardTests.swift
//  TicTacToe
//
//  Created by 김민우 on 7/30/25.
//
import Foundation
import Testing
@testable import TicTacToeMac


// MARK: Tests
@Suite("GameBoard")
struct GameBoardTests {
    struct SetUp {
        let tictactoeRef: TicTacToe
        let gameBoardRef: GameBoard
        init() async throws {
            self.tictactoeRef = await TicTacToe()
            self.gameBoardRef = try await getGameBoard(tictactoeRef)
        }
        
        @Test func whenGameBoardIsDeleted() async throws {
            // given
            try await #require(gameBoardRef.id.isExist == true)
            
            await gameBoardRef.setHook {
                await gameBoardRef.delete()
            }
            
            // when
            await gameBoardRef.setUp()
            
            // then
            let issue = try #require(await gameBoardRef.issue)
            #expect(issue.reason == "gameBoardIsDeleted")
        }
        @Test func whenAlreadySetUp() async throws {
            // given
            await gameBoardRef.setUp()
            try await #require(gameBoardRef.cards.isEmpty == false)
            try await #require(gameBoardRef.issue == nil)
            
            // when
            await gameBoardRef.setUp()
            
            // then
            let issue = try #require(await gameBoardRef.issue)
            #expect(issue.reason == "alreadySetUp")
        }
        
        @Test func createNineGameCards() async throws {
            // given
            try await #require(gameBoardRef.cards.isEmpty == true)
            
            // when
            await gameBoardRef.setUp()
            
            // then
            await #expect(gameBoardRef.cards.count == 9)
            
            for gameCard in await gameBoardRef.cards.values {
                let gameCardRef = try #require(await gameCard.ref)
                let position = gameCardRef.position
                
                await #expect(gameBoardRef.cards[position] == gameCard)
            }
        }
    }
    
    struct RemoveBoard {
        let tictactoeRef: TicTacToe
        let gameBoardRef: GameBoard
        init() async throws {
            self.tictactoeRef = await TicTacToe()
            self.gameBoardRef = try await getGameBoard(tictactoeRef)
        }
        
        @Test func whenGameBoardIsDeleted() async throws {
            // given
            try await #require(gameBoardRef.id.isExist == true)
            
            await gameBoardRef.setHook {
                await gameBoardRef.delete()
            }
            
            // when
            await gameBoardRef.removeBoard()
            
            // then
            let issue = try #require(await gameBoardRef.issue)
            #expect(issue.reason == "gameBoardIsDeleted")
        }
        
        @Test func deleteBoard() async throws {
            // given
            try await #require(gameBoardRef.id.isExist == true)
            
            // when
            await gameBoardRef.removeBoard()
            
            // then
            await #expect(gameBoardRef.id.isExist == false)
        }
        @Test func deleteCards() async throws {
            // given
            await gameBoardRef.setUp()
            
            try await #require(gameBoardRef.cards.count > 0 )
            let gameCards = await gameBoardRef.cards.values
            
            // when
            await gameBoardRef.removeBoard()
            
            // then
            for gameCard in gameCards {
                await #expect(gameCard.isExist == false)
            }
        }
        @Test func removeBoard_TicTacToe() async throws {
            // given
            let gameBoard = gameBoardRef.id
            let tictactoeRef = try #require(await gameBoardRef.tictactoe.ref)
            
            try await #require(tictactoeRef.boards.contains(gameBoard) == true)
            
            // when
            await gameBoardRef.removeBoard()
            
            // then
            await #expect(tictactoeRef.boards.contains(gameBoard) == false)
        }
    }
}



// MARK: Helphers
private func getGameBoard(_ tictactoeRef: TicTacToe) async throws -> GameBoard {
    try await #require(tictactoeRef.boards.isEmpty)
    
    await tictactoeRef.createGame()
    
    try await #require(tictactoeRef.boards.count == 1)
    
    return try #require(await tictactoeRef.boards.first?.ref)
}
