//
//  GameCard.swift
//  TicTacToe
//
//  Created by 김민우 on 7/30/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class GameCard {
    // MARK: core
    init(position: Int, board: GameBoard.ID) {
        self.board = board
        self.position = position
        
        GameCardManager.register(self)
    }
    func delete() {
        GameCardManager.unregister(self.id)
    }
    
    // MARK: state
    nonisolated let id = ID()
    nonisolated let board: GameBoard.ID
    nonisolated let winPositions: [Set<Int>] = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]
    
    public nonisolated let position: Int
    public var owner: GameBoard.Player?
    
    
    public var issue: ObjectIssue?
    internal func setIssue(_ error: Error) {
        self.issue = .init(error.rawValue)
    }
    
    internal var callback: Callback?
    internal func setCallback(_ callback: @escaping Callback) {
        self.callback = callback
    }
    
    
    // MARK: action
    public func select() async {
        print("\(#file):\(#line) - \(#function) start")
        
        // capture
        await callback?()
        guard id.isExist else {
            setIssue(.gameCardIsDeleted)
            print("gameCard가 존재하지 않아 실행 취소됩니다. ")
            return
        }
        guard owner == nil else {
            setIssue(.alreadySelected)
            print("이미 선택된 Card입니다.")
            return
        }
        let gameBoardRef = self.board.ref!
        
        // mutate
        guard gameBoardRef.isEnd == false else {
            setIssue(.gameIsEnd)
            print("game이 종료되어 취소됩니다.")
            return
        }
        self.owner = gameBoardRef.currentPlayer
        gameBoardRef.changePlayer()
        
        for winPosition in winPositions {
            if winPosition.isSubset(of: gameBoardRef.XPositions) {
                gameBoardRef.isEnd = true
                gameBoardRef.result = .win(.X)
                break
            }
            
            if winPosition.isSubset(of: gameBoardRef.OPositions) {
                gameBoardRef.isEnd = true
                gameBoardRef.result = .win(.O)
                break
            }
        }
        
        if gameBoardRef.isEnd == false && (gameBoardRef.XPositions.count + gameBoardRef.OPositions.count == 9) {
            gameBoardRef.isEnd = true
            gameBoardRef.result = .draw
        }
    }

    
    // MARK: value
    public enum Error: String, Swift.Error {
        case gameCardIsDeleted
        case gameIsEnd
        case alreadySelected
    }
    
    public nonisolated struct ID: Sendable, Hashable, Identifiable {
        public let id = UUID()
        nonisolated init() { }
    
        @MainActor
        public var isExist: Bool {
            GameCardManager.container[self] != nil
        }
        
        @MainActor
        public var ref: GameCard? {
            GameCardManager.container[self]
        }
    }
    
    public nonisolated struct ObjectIssue: Sendable, Hashable, Identifiable {
        public let id = UUID()
        public let reason: String
        
        public init(_ reason: String) {
            self.reason = reason
        }
    }
    
    internal typealias Callback = @Sendable () async -> Void
}



// MARK: ObjectManager
@MainActor @Observable
fileprivate final class GameCardManager {
    // MARK: state
    static var container: [GameCard.ID: GameCard] = [:]
    static func register(_ object: GameCard) {
        container[object.id] = object
    }
    static func unregister(_ id: GameCard.ID) {
        container[id] = nil
    }
}

