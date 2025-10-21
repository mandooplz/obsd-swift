//
//  GameCardView.swift
//  TicTacToeMac
//
//  Created by 김민우 on 7/31/25.
//

import SwiftUI



struct GameCardView: View {
    let gameCard: GameCard

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)

            if let owner = gameCard.owner {
                Text(owner == .X ? "X" : "O")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        // event
        .onTapGesture {
            Task {
                await gameCard.select()
            }
        }
        
        // layout
        .padding()
    }
}



