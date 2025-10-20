//
//  Cheetos.swift
//  Cheetos
//
//  Created by 김민우 on 8/28/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class Cheetos: Sendable {
    // MARK: core
    public init(enableDelay: Bool = false) {
        self.enableDelay = enableDelay
        
        CheetosManager.register(self)
    }
    internal func delete() {
        CheetosManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let enableDelay: Bool
    
    public var textInput: String = ""

    public var messages: [any MessageIDRepresentable] = []
    
    
    // MARK: action
    public func newFortune() async {
        // mutate
        let fortureRef = Fortune(owner: self.id)
        self.messages.append(fortureRef.id)
    }
    public func newAdvice() async {
        // capture
        fatalError()
    }
    
    public func createMyMessage() async {
        // capture
        let textInput = self.textInput
        
        // mutate
        let myMessageRef = MyMessage(owner: self.id, content: textInput)
        self.messages.append(myMessageRef.id)
    }
    
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let rawValue = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            CheetosManager.container[self] != nil
        }
        public var ref: Cheetos? {
            CheetosManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor @Observable
fileprivate final class CheetosManager: Sendable {
    // MARK: core
    static var container: [Cheetos.ID: Cheetos] = [:]
    static func register(_ object: Cheetos) {
        self.container[object.id] = object
    }
    static func unregister(_ id: Cheetos.ID) {
        self.container[id] = nil
    }
}
