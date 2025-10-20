//
//  MyMessage.swift
//  Cheetos
//
//  Created by 김민우 on 8/28/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class MyMessage: MessageInterface {
    // MARK: core
    internal init(owner: Cheetos.ID, content: String) {
        self.owner = owner
        self.content = content
        
        MyMessageManager.register(self)
    }
    internal func delete() {
        MyMessageManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    internal nonisolated let owner: Cheetos.ID
    
    public var content: String? = nil
    public nonisolated let createdAt: Date? = .now
    
    public var isLoading: Bool = false
    public nonisolated let isMyMessage: Bool = true
    
    
    // MARK: action
    
    
    
    // MARK: value
    @MainActor
    public struct ID: MessageIDRepresentable, Hashable {
        public let rawValue = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            MyMessageManager.container[self] != nil
        }
        public var ref: MyMessage? {
            MyMessageManager.container[self]
        }
    }
}



// MARK: ObjectManager
@MainActor @Observable
fileprivate final class MyMessageManager: Sendable {
    // MARK: core
    static var container: [MyMessage.ID:MyMessage] = [:]
    static func register(_ object:MyMessage) {
        container[object.id] = object
    }
    static func unregister(_ id:MyMessage.ID) {
        container[id] = nil
    }
}
