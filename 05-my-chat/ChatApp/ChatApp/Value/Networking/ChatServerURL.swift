//
//  ChatServerURL.swift
//  ChatApp
//
//  Created by 김민우 on 11/6/25.
//
import Foundation
import SwiftLogger

private let logger = SwiftLogger("ChatServerURL")


// MARK: Value
struct ChatServerURL {
    // MARK: core
    let httpURL = URL(string: "http://172.30.1.69:8080")!
    let wsURL = URL(string: "ws://172.30.1.69:8080")!
    
     
    // MARK: operator
    func getHTTPRequest(path: String?, method: HTTPMethod, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        // configure URL
        var url = httpURL
        if let path, path.isEmpty == false {
            url.appendPathComponent(path)
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error.invalidURL(path ?? httpURL.path)
        }
        if queryItems.isEmpty == false {
            components.queryItems = queryItems
        }
        guard let finalURL = components.url else {
            throw Error.invalidURL(path ?? httpURL.path)
        }
        
        
        // configure URLRequest
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        
        // return
        return request
    }
    
    func startWSTask(path: String, queryItems: [URLQueryItem]) throws -> URLSessionWebSocketTask {
        logger.info("add path: \(path)")
        var url = wsURL
        if path.isEmpty == false {
            url.appendPathComponent(path)
        }
        
        logger.info("configure URLComponents")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error.invalidURL(path)
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let socketURL = components.url else {
            throw Error.invalidURL(path)
        }
        
        logger.info("configure URLSessionWebSocketTask")
        let task = URLSession.shared.webSocketTask(with: socketURL)
        
        logger.info("start WebSocketTask")
        task.resume()
        
        logger.end()
        return task
    }
    
    
    // MARK: value
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum Error: Swift.Error {
        case invalidURL(String)
        case unexpectedResponse
        case unexpectedStatusCode(Int)
    }
}
