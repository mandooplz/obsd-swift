//
//  JSON.swift
//  ChatApp
//
//  Created by 김민우 on 11/6/25.
//
import Foundation

public enum JSON: Sendable {
    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
