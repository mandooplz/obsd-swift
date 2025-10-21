//
//  TicTacToe.swift
//  TicTacToe
//
//  Created by 김민우 on 7/30/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class TicTacToe {
    // MARK: core
    public init() {
        TicTacToeManager.register(self)
    }
    func delete() {
        TicTacToeManager.unregister(self.id)
    }
    
    // MARK: state
    nonisolated let id = ID()
    
    internal var boards: Set<GameBoard.ID> = []
    public var boardList: [GameBoard.ID] {
        boards
            .compactMap { $0.ref }
            .sorted { $0.createdAt < $1.createdAt }
            .map { $0.id }
    }
    public var boardCount: Int {
        boards.count
    }
                                            
    public var issue: ObjectIssue?
    func setIssue(_ error: Error) {
        self.issue = .init(error.rawValue)
    }
    
    internal var callback: Callback?
    internal func setCallback(_ callback: @escaping Callback) {
        self.callback = callback
    }
    
    
    // MARK: action
    public func createGame() async {
        print("\(#file):\(#line) - \(#function) start")
        
        // capture
        await callback?()
        guard id.isExist else {
            setIssue(.tictactoeIsDeleted)
            print(#file, #line, #function, "TicTacToe가 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        // mutate
        let gameBoardRef = GameBoard(tictactoe: self.id)
        self.boards.insert(gameBoardRef.id)
    }
    
    
    // MARK: value
    public nonisolated struct ID: Sendable, Hashable, Identifiable {
        public let id = UUID()
        nonisolated init() { }
        
        @MainActor
        public var isExist: Bool {
            TicTacToeManager.container[self] != nil
        }
        
        @MainActor
        public var ref: TicTacToe? {
            TicTacToeManager.container[self]
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
    
    public enum Error: String, Swift.Error {
        case tictactoeIsDeleted
    }
}



// MARK: ObjectManager
@MainActor @Observable
fileprivate final class TicTacToeManager {
    // MARK: state
    static var container: [TicTacToe.ID: TicTacToe] = [:]
    static func register(_ object: TicTacToe) {
        container[object.id] = object
    }
    static func unregister(_ id: TicTacToe.ID) {
        container[id] = nil
    }
}
