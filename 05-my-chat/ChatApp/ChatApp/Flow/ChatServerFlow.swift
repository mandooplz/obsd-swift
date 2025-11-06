//
//  ChatServerFlow.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//
import Foundation
import SwiftLogger

private let logger = SwiftLogger("ChatServerFlow")


// MARK: Flow
actor ChatServerFlow {
    // MARK: value
    static let shared = ChatServerFlow()
    private init() { }
    
    private let url = ChatServerURL()
    
    
    // MARK: Flow
    @concurrent
    func check() async throws {
        logger.start()
        
        logger.info("makeRequest")
        let request = try url.getHTTPRequest(path: nil, method: .get)
        
        logger.info("networking")
        let (_, response) = try await request.getDataByURLSession()
        
        logger.info("validate URLResponse")
        try response.validateStatusCode()
        
        logger.end()
        return
    }
    
    @concurrent
    func addMessage(ticket: NewMsgTicket) async throws {
        logger.start()
        
        logger.info("configure URLRequest")
        let request = try url.getHTTPRequest(path: "addMessage", method: .post)
            .addJSONBody(ticket)
        
        logger.info("Send HTTPRequest")
        let (_, response) = try await request.getDataByURLSession()
        
        logger.info("URLResponse validation")
        try response.validateStatusCode()
        
        logger.end()
    }

    @concurrent
    func register(credential: Credential) async throws {
        logger.start()
        
        logger.info("Configure URLRequest")
        let request = try url.getHTTPRequest(path: "register", method: .post)
            .addJSONBody(credential)
            
        logger.info("Send HTTPRequest")
        let (_, response) = try await request.getDataByURLSession()
        
        logger.info("URLResponse validate")
        try response.validateStatusCode()
        
        logger.end()
    }

    @concurrent
    func authenticate(credential: Credential) async throws -> Bool {
        logger.start()
        
        logger.info("Configure URLRequest")
        let request = try url.getHTTPRequest(path: "auth", method: .post)
            .addJSONBody(credential)
        
        logger.info("Send HTTPRequest")
        let (data, response) = try await request.getDataByURLSession()
        
        logger.info("URLResponse validation")
        try response.validateStatusCode()
        
        logger.info("decoding from json")
        let decoder = JSON.decoder
        let result = try decoder.decode(Bool.self, from: data)
        
        logger.end()
        return result
    }

    @concurrent
    func getMessages(credential: Credential) async throws -> [Message] {
        logger.start()
        
        logger.info("Configure URLRequest")
        let queryItems = [
            URLQueryItem(name: "email", value: credential.email),
            URLQueryItem(name: "password", value: credential.password)
        ]
        
        let request = try url.getHTTPRequest(path: "getMessages", method: .get, queryItems: queryItems)
        
        logger.info("Send HTTPRequest")
        let (data, response) = try await request.getDataByURLSession()
        
        logger.info("Validate URLResponse")
        try response.validateStatusCode()
        
        logger.info("Parsing Data to [Message]")
        let decoder = JSON.decoder
        let result: [Message]
        if data.isEmpty {
            result = []
        } else {
            result = try decoder.decode([Message].self, from: data)
        }
        
        logger.end()
        return result
    }

    func subscribe(
        clientId: UUID,
        onText: (@Sendable (String) -> Void)? = nil,
        onData: (@Sendable (Data) -> Void)? = nil,
        onClose: (@Sendable (Error?) -> Void)? = nil
    ) async throws {
        logger.start()
        let query = [URLQueryItem(name: "client", value: clientId.uuidString)]

        logger.info("Start WebSocketSession")
        let task = try url.startWSTask(path: "ws", queryItems: query)
        
        logger.info("Configure URLRequest")
        let request = try url.getHTTPRequest(path: "subscribe",
                                             method: .post,
                                             queryItems: query)
        
        logger.info("Send HTTPRequest to /subscribe")
        let (_, response) = try await request.getDataByURLSession()
        
        logger.info("Validate URLResponse")
        try response.validateStatusCode()

        

        // 시작 즉시 수신 루프 연결
        startReceiveLoop(
            task: task,
            onText: onText,
            onData: onData,
            onClose: onClose
        )
    }
    
    private func startReceiveLoop(
        task: URLSessionWebSocketTask,
        onText: (@Sendable (String) -> Void)? = nil,
        onData: (@Sendable (Data) -> Void)? = nil,
        onClose: (@Sendable (Error?) -> Void)? = nil
    ) {
        @Sendable func _loop() {
            task.receive { result in
                switch result {
                case .failure(let error):
                    onClose?(error)
                case .success(let message):
                    switch message {
                    case .string(let text):
                        onText?(text)
                    case .data(let data):
                        onData?(data)
                    @unknown default:
                        break
                    }
                    // 다음 메시지를 계속 받기 위해 재귀 루프
                    _loop()
                }
            }
        }
        _loop()
    }
}
