//
//  ChatServerFlow.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//
import Foundation
import SwiftLogger

//private let logger = SwiftLogger("ChatServerFlow")
//
//
//// MARK: Flow
//actor ChatServerFlow {
//    // MARK: value
//    static let shared = ChatServerFlow()
//    private init() { }
//    
//    private let url = ChatServerURL()
//    
//    
//    // MARK: Flow
//    @concurrent
//    func check() async throws {
//        logger.start()
//        
//        logger.info("makeRequest")
//        let request = try url.getHTTPRequest(path: nil, method: .get)
//        
//        logger.info("networking")
//        let (_, response) = try await request.getDataByURLSession()
//        
//        logger.info("validate URLResponse")
//        try response.validateStatusCode()
//        
//        logger.end()
//        return
//    }
//    
//    @concurrent
//    func addMessage(ticket: NewMsgTicket) async throws {
//        logger.start()
//        
//        logger.info("configure URLRequest")
//        let request = try url.getHTTPRequest(path: "addMessage", method: .post)
//            .addJSONBody(ticket)
//        
//        logger.info("Send HTTPRequest")
//        let (_, response) = try await request.getDataByURLSession()
//        
//        logger.info("URLResponse validation")
//        try response.validateStatusCode()
//        
//        logger.end()
//    }
//
//    @concurrent
//    func register(credential: Credential) async throws {
//        logger.start()
//        
//        logger.info("Configure URLRequest")
//        let request = try url.getHTTPRequest(path: "register", method: .post)
//            .addJSONBody(credential)
//            
//        logger.info("Send HTTPRequest")
//        let (_, response) = try await request.getDataByURLSession()
//        
//        logger.info("URLResponse validate")
//        try response.validateStatusCode()
//        
//        logger.end()
//    }
//
//    @concurrent
//    func authenticate(credential: Credential) async throws -> Bool {
//        logger.start()
//        
//        logger.info("Configure URLRequest")
//        let request = try url.getHTTPRequest(path: "auth", method: .post)
//            .addJSONBody(credential)
//        
//        logger.info("Send HTTPRequest")
//        let (data, response) = try await request.getDataByURLSession()
//        
//        logger.info("URLResponse validation")
//        try response.validateStatusCode()
//        
//        logger.info("decoding from json")
//        let decoder = JSON.decoder
//        let result = try decoder.decode(Bool.self, from: data)
//        
//        logger.end()
//        return result
//    }
//
//    @concurrent
//    func getMessages(credential: Credential) async throws -> [Message] {
//        logger.start()
//        
//        logger.info("Configure URLRequest")
//        let queryItems = [
//            URLQueryItem(name: "email", value: credential.email),
//            URLQueryItem(name: "password", value: credential.password)
//        ]
//        
//        let request = try url.getHTTPRequest(path: "getMessages", method: .get, queryItems: queryItems)
//        
//        logger.info("Send HTTPRequest")
//        let (data, response) = try await request.getDataByURLSession()
//        
//        logger.info("Validate URLResponse")
//        try response.validateStatusCode()
//        
//        logger.info("Parsing Data to [Message]")
//        let decoder = JSON.decoder
//        let result: [Message]
//        if data.isEmpty {
//            result = []
//        } else {
//            result = try decoder.decode([Message].self, from: data)
//        }
//        
//        logger.end()
//        return result
//    }
//}
