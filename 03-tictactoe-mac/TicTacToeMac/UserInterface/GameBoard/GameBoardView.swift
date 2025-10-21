//
//  GameBoardView.swift
//  TicTacToeMac
//
//  Created by 김민우 on 7/31/25.
//
import SwiftUI



// MARK: View
struct GameBoardView: View {
    // MARK: core
    let gameBoardRef: GameBoard
    init(_ gameBoardRef: GameBoard) {
        self.gameBoardRef = gameBoardRef
    }

    
    // MARK: body
    var body: some View {
        VStack {
            HStack {
                Text("Current Player: \(gameBoardRef.currentPlayer == .X ? "X" : "O")")
                
                Spacer()
                
                if gameBoardRef.isEnd { GameResultLabel }
            }
            .font(.title)
            .padding()

            CardsGrid
        }
        
        // navigtion
        .toolbar {
            if gameBoardRef.isEnd {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await gameBoardRef.removeBoard()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}


// MARK: Component
extension GameBoardView {
    var GameResultLabel: some View {
        VStack {
            if let result = gameBoardRef.result {
                switch result {
                case .draw:
                    Text("It's a draw!")
                        
                case .win(let player):
                    Text("\(player.rawValue) wins!")
                        .foregroundStyle(Color.blue)
                }
            }
        }
    }
    var CardsGrid: some View {
        Grid {
            ForEach(0..<3) { row in
                GridRow {
                    ForEach(0..<3) { col in
                        let position = row * 3 + col
                        if let cardID = gameBoardRef.cards[position], let card = cardID.ref {
                            GameCardView(gameCard: card)
                        }
                    }
                }
            }
        }
    }
}



// MARK: Preview
private struct GameBoardPreview: View {
    let tictactoeRef = TicTacToe()
    
    var body: some View {
        if let gameBoard = tictactoeRef.boardList.first,
           let gameBoardRef = gameBoard.ref {
            GameBoardView(gameBoardRef)
        } else {
            ProgressView("GameBoard Preview")
                .task {
                    await tictactoeRef.createGame()
                }
        }
    }
}

#Preview {
    GameBoardPreview()
}
