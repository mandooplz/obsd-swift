//
//  Message.swift
//  Cheetos
//
//  Created by 김민우 on 8/28/25.
//
import Foundation


// MARK: Interface
@MainActor
public protocol MessageInterface: Sendable {
    associatedtype ID: MessageIDRepresentable where ID.Object == Self
    
    var id: ID { get }
    var content: String? { get }
    var createdAt: Date? { get }
    
    var isMyMessage: Bool { get }
    var isLoading: Bool { get }
}


@MainActor
public protocol MessageIDRepresentable: Sendable {
    associatedtype Object: MessageInterface
    
    var rawValue: UUID { get }
    var isExist: Bool { get }
    var ref: Object? { get }
}
