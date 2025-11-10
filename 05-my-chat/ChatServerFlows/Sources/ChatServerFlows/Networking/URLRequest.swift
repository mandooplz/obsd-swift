//
//  URLRequest.swift
//  ChatApp
//
//  Created by 김민우 on 11/6/25.
//
import Foundation


//// MARK: Value
//extension URLRequest {
//    // MARK: operator
//    func getDataByURLSession() async throws -> (Data, URLResponse) {
//        return try await URLSession.shared.data(for: self)
//    }
//    
//    func addJSONBody<T: Encodable>(_ value: T) throws -> Self {
//        let data = try JSON.encoder.encode(value)
//        
//        var newRequest = self
//        newRequest.httpBody = data
//        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return newRequest
//    }
//}
