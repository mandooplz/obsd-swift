//
//  ChatServerHub.swift
//  ChatApp
//
//  Created by 김민우 on 11/7/25.
//
import Foundation
import SwiftLogger

private let logger = SwiftLogger("ChatServerHub")


// MARK: Hub
actor ChatServerHub {
    // MARK: core
    static let shared = ChatServerHub()
    private init() { }
    
    
    // MARK: state
    nonisolated let clientId = UUID()
    nonisolated let url = ChatServerURL()
    
    var newMessageFlow: NewMessageFlow? = nil
    func setNewMessageFlow(_ flow: @escaping NewMessageFlow) {
        self.newMessageFlow = flow
    }
    
    var closeFlow: CloseFlow? = nil
    func setCloseFlow(_ flow: @escaping CloseFlow) {
        self.closeFlow = flow
    }
    
    
    // MARK: action
    func connect() async {
        logger.start()
        
        do {
            logger.info("Start WebSocketSession")
            let wsQuery = [URLQueryItem(name: "token", value: clientId.uuidString)]
            let task = try url.startWSTask(path: "ws", queryItems: wsQuery)
            
            logger.info("Configure URLRequest")
            let subscribeQuery = [URLQueryItem(name: "client", value: clientId.uuidString)]
            let request = try url.getHTTPRequest(path: "subscribe",
                                                 method: .post,
                                                 queryItems: subscribeQuery)
            
            logger.info("Send HTTPRequest to /subscribe")
            let (_, response) = try await request.getDataByURLSession()
            
            logger.info("Validate URLResponse")
            try response.validateStatusCode()
            
            await startReceiveLoop(task: task)
        } catch {
            logger.error(error)
        }
    }
    
    
    // MARK: helpher
    private func startReceiveLoop(task: URLSessionWebSocketTask) async {
        @Sendable func _loop() async {
            let newMessageFlow = await self.newMessageFlow
            let closeFlow = await self.closeFlow
            
            task.receive { result in
                switch result {
                case .failure(let error):
                    closeFlow?(error)
                case .success(let message):
                    switch message {
                    case .string(let text):
                        // NewMessageEvent를 처리
                        logger.info("Text가 도착했습니다.")
                        
                        guard let data = text.data(using: .utf8) else {
                            logger.error("웹소켓 메시지를 Data로 변환할 수 없습니다: \(text)")
                            return
                        }
                        
                        do {
                            let event = try JSON.decoder.decode(NewMsgEvent.self,
                                                                from: data)
                            newMessageFlow?(event)
                        } catch {
                            logger.error(error)
                        }
                    case .data(let data):
                        logger.info("Data가 도착했습니다. \(data.count)")
                    @unknown default:
                        break
                    }
                    
                    
                    Task {
                        await _loop()
                    }
                }
            }
        }
        
        await _loop()
    }
    
    
    // MARK: value
    typealias NewMessageFlow = @Sendable (NewMsgEvent) -> Void
    typealias CloseFlow = @Sendable (Error?) -> Void
}
