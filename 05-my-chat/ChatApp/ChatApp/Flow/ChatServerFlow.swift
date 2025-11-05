//
//  ChatServerFlow.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//
import Foundation


// MARK: Flow
actor ChatServerFlow {
    // MARK: value
    private let baseURL: URL = URL(string: "http://172.30.1.69:8080")!
    private let session: URLSession = .shared
    private var webSocketTask: URLSessionWebSocketTask?
    
    static let shared = ChatServerFlow()
    private init() { }
    
    
    // MARK: flow
    @concurrent
    func check() async throws {
        let request = try makeRequest(path: nil, method: .get)
        let (_, response) = try await session.data(for: request)
        try validate(response: response)
    }
    
    @concurrent
    func addMessage(ticket: NewMsgTicket) async throws {
        var request = try makeRequest(path: "addMessage", method: .post)
        
        let encoder = makeJSONEncoder()
        request.httpBody = try encoder.encode(ticket)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await session.data(for: request)
        try validate(response: response)
    }

    @concurrent
    func register(credential: Credential) async throws {
        var request = try makeRequest(path: "register", method: .post)
        
        let encoder = makeJSONEncoder()
        request.httpBody = try encoder.encode(credential)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (_, response) = try await session.data(for: request)
        
        try validate(response: response)
    }

    @concurrent
    func authenticate(credential: Credential) async throws -> Bool {
        var request = try makeRequest(path: "auth", method: .post)
        
        let encoder = makeJSONEncoder()
        request.httpBody = try encoder.encode(credential)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        try validate(response: response)
        let decoder = JSONDecoder()
        return try decoder.decode(Bool.self, from: data)
    }

    @concurrent
    func getMessages(credential: Credential) async throws -> [Message] {
        let queryItems = [
            URLQueryItem(name: "email", value: credential.email),
            URLQueryItem(name: "password", value: credential.password)
        ]
        let request = try makeRequest(path: "getMessages", method: .get, queryItems: queryItems)
        
        let (data, response) = try await session.data(for: request)
        try validate(response: response)
        
        let decoder = makeJSONDecoder()
        guard data.isEmpty == false else { return [] }
        return try decoder.decode([Message].self, from: data)
    }

    func subscribe(
        clientId: UUID,
        onText: (@Sendable (String) -> Void)? = nil,
        onData: (@Sendable (Data) -> Void)? = nil,
        onClose: (@Sendable (Error?) -> Void)? = nil
    ) async throws {
        let query = [URLQueryItem(name: "client", value: clientId.uuidString)]

        let request = try makeRequest(path: "subscribe", method: .post, queryItems: query)
        let (_, response) = try await session.data(for: request)
        try validate(response: response)

        let socketURL = try makeWebSocketURL(path: "ws", queryItems: [URLQueryItem(name: "token", value: clientId.uuidString)])
        let task = session.webSocketTask(with: socketURL)
        self.webSocketTask = task
        task.resume()

        // 시작 즉시 수신 루프 연결
        startReceiveLoop(
            task: task,
            onText: onText,
            onData: onData,
            onClose: onClose
        )
    }
}


// MARK: Helper
private extension ChatServerFlow {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum FlowError: Error {
        case invalidURL(String)
        case unexpectedResponse
        case unexpectedStatusCode(Int)
    }
    
    nonisolated func makeRequest(path: String?, method: HTTPMethod, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        var url = baseURL
        if let path, path.isEmpty == false {
            url.appendPathComponent(path)
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw FlowError.invalidURL(path ?? baseURL.path)
        }
        if queryItems.isEmpty == false {
            components.queryItems = queryItems
        }
        guard let finalURL = components.url else {
            throw FlowError.invalidURL(path ?? baseURL.path)
        }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        return request
    }
    
    nonisolated func makeWebSocketURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        var url = baseURL
        if path.isEmpty == false {
            url.appendPathComponent(path)
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw FlowError.invalidURL(path)
        }
        components.scheme = "ws"
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        
        guard let finalURL = components.url else {
            throw FlowError.invalidURL(path)
        }
        return finalURL
    }
    
    nonisolated func validate(response: URLResponse, allowedStatusCodes: Range<Int> = 200..<300) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FlowError.unexpectedResponse
        }
        guard allowedStatusCodes.contains(httpResponse.statusCode) else {
            throw FlowError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    nonisolated func makeJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    nonisolated func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    nonisolated func startReceiveLoop(
        task: URLSessionWebSocketTask,
        onText: (@Sendable (String) -> Void)? = nil,
        onData: (@Sendable (Data) -> Void)? = nil,
        onClose: (@Sendable (Error?) -> Void)? = nil
    ) {
        func _loop() {
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

    // 간단한 keep-alive. 서버가 ping/pong을 요구하지 않는다면 생략해도 무방함.
    nonisolated func schedulePing(_ task: URLSessionWebSocketTask) {
        // URLSessionWebSocketTask는 내부적으로도 핑/퐁을 처리하지만,
        // 명시적으로 30초마다 핑을 보내 연결을 유지합니다.
        let interval: TimeInterval = 30
        func _ping() {
            task.sendPing { _ in
                // 오류가 있어도 다음 핑을 예약 (연결이 닫히면 자연스럽게 중단)
                DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
                    _ping()
                }
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
            _ping()
        }
    }
}
