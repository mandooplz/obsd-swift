//
//  TicTacToeTests.swift
//  TicTacToe
//
//  Created by 김민우 on 7/30/25.
//
import Foundation
import Testing
@testable import TicTacToeMac


// MARK: Tests
@Suite("TicTacToe")
struct TicTacToeTests {
    struct CreateGame {
        let tictactoeRef: TicTacToe
        init() async throws {
            self.tictactoeRef = await TicTacToe()
        }
        
        @Test func whenTicTacToeIsDeleted() async throws {
            // given
            try await #require(tictactoeRef.id.isExist == true)
            
            await tictactoeRef.setCallback {
                await tictactoeRef.delete()
            }
            
            // when
            await tictactoeRef.createGame()
            
            // then
            let issue = try #require(await tictactoeRef.issue)
            #expect(issue.reason == "tictactoeIsDeleted")
        }
        
        @Test func appendGameBoard_TicTacToe() async throws {
            // given
            try await #require(tictactoeRef.boards.isEmpty)
            try await #require(tictactoeRef.boardList.isEmpty)
            try await #require(tictactoeRef.boardCount == 0)
            
            // when
            await tictactoeRef.createGame()
            
            // then
            try await #require(tictactoeRef.boards.count == 1)
            try await #require(tictactoeRef.boardCount == 1)
            try await #require(tictactoeRef.boardList.count == 1)
        }
        @Test func createGameBoard() async throws {
            // given
            try await #require(tictactoeRef.boards.isEmpty)
            
            // when
            await tictactoeRef.createGame()
            
            // then
            let gameBoard = try #require(await tictactoeRef.boards.first)
            await #expect(gameBoard.isExist == true)
        }
    }
}

