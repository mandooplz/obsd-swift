//
//  Hub.swift
//  ChatServer
//
//  Created by 김민우 on 11/4/25.
//
import Foundation
import Vapor
import SwiftLogger

private let logger = SwiftLogger("Hub")


// MARK: MessageBroker
actor Hub {
    static let shared = Hub()
    private var sockets: [UUID: WebSocket] = [:]
    
    // 등록
    func join(clientId: UUID, socket: WebSocket) {
        sockets[clientId]?.close(promise: nil) // 중복 접속 있으면 정리
        sockets[clientId] = socket
        logger.info("[Hub] joined \(clientId)")
    }
 
    // 정리
    func leave(clientId: UUID) {
        sockets.removeValue(forKey: clientId)
    }
    
    // 전송
    func sendWithout(clientId: UUID, event: NewMsgEvent) {
        logger.start()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(event),
              let jsonString = String(data: data, encoding: .utf8) else {
            logger.error("Encoding failed for event: \(event)")
            return
        }
        
        for (id, ws) in sockets {
            if id == clientId { continue }
            if ws.isClosed { continue }
            ws.send(jsonString, promise: nil)
        }
    }
}
