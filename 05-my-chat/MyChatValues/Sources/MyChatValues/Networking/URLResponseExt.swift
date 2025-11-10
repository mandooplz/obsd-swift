//
//  URLResponseExtension.swift
//  ChatApp
//
//  Created by 김민우 on 11/6/25.
//
import Foundation


// MARK: Value
public extension URLResponse {
    func validateStatusCode(allowedStatusCodes: Range<Int> = 200..<300) throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw MyError.unexpectedResponse
        }
        guard allowedStatusCodes.contains(httpResponse.statusCode) else {
            throw MyError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
    
    enum MyError: Swift.Error {
        case unexpectedResponse
        case unexpectedStatusCode(Int)
    }
}
