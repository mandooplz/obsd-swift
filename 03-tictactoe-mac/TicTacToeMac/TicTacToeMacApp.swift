//
//  TicTacToeMacApp.swift
//  TicTacToeMac
//
//  Created by 김민우 on 7/31/25.
//
import SwiftUI



// MARK: App
@main
struct TicTacToeMacApp: App {
    let tictactoeRef = TicTacToe()
    
    var body: some Scene {
        WindowGroup {
            TicTacToeView(tictactoeRef)
        }
        
        // command
        .commands {
            CommandMenu("Game") {
                Button("게임 생성") {
                    Task {
                        await tictactoeRef.createGame()
                    }
                }
            }
        }
    }
}
