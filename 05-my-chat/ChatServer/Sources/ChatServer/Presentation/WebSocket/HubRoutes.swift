//
//  ChatServerHubUI.swift
//  ChatServer
//
//  Created by 김민우 on 11/7/25.
//
import Foundation
import Vapor
import MyChatValues


// MARK: UI
func routeChatServerHub(_ app: Application) throws {
    // 구독 Flow
    // WS /ws?token={UUID}
    // ws://host:8080/ws?token=(UUID형식 문자열값)
    app.webSocket("ws") { req, ws in
        Task {
            do {
                // clientId 추출
                guard let token = req.query[String.self, at: "token"] else {
                    req.logger.error("Client에서 token이 전달되지 않았습니다.")
                    try await ws.send("token 쿼리 매개변수가 존재하지 않습니다.")
                    try await ws.close()
                    return
                }
                guard let clientId = UUID(uuidString: token) else {
                    req.logger.error("Token이 UUID 형식이 아닙니다.")
                    try await ws.send("token이 UUID 형식이 아닙니다.")
                    return
                }
                
                await Hub.shared.join(req: req, clientId: clientId, socket: ws)
                
                // 5) 종료 처리
                ws.onClose.whenComplete { outcome in
                    Task {
                        // 연결 종료 사유 추출 (정상/에러)
                        let reason: String
                        switch outcome {
                        case .success:
                            reason = "client closed"
                        case .failure(let error):
                            reason = "error: \(error.localizedDescription)"
                        }

                        req.logger.info("WebSocket closed: \(clientId) - \(reason)")
                        await Hub.shared.leave(clientId: clientId)
                        let _ = await MainActor.run {
                            ChatServer.shared.subscribers.removeValue(forKey: clientId)
                        }
                    }
                }
            } catch {
                req.logger.error("Upgrade auth failed: \(error.localizedDescription)")
                ws.close(promise: nil)
            }
        }
    }
}



// MARK: MessageBroker
actor Hub {
    static let shared = Hub()
    private var sockets: [UUID: WebSocket] = [:]
    
    // 등록
    func join(req: Request, clientId: UUID, socket: WebSocket) {
        sockets[clientId]?.close(promise: nil) // 중복 접속 있으면 정리
        sockets[clientId] = socket
        req.logger.info("[Hub] joined \(clientId)")
    }
 
    // 정리
    func leave(clientId: UUID) {
        sockets.removeValue(forKey: clientId)
    }
    
    // 전송
    func sendWithout(req: Request? = nil, clientId: UUID, event: NewMsgEvent) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(event),
              let jsonString = String(data: data, encoding: .utf8) else {
            req?.logger.error("Encoding failed for event: \(event)")
            return
        }
        
        for (id, ws) in sockets {
            if id == clientId { continue }
            if ws.isClosed { continue }
            ws.send(jsonString, promise: nil)
        }
    }
}

