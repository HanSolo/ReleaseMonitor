//
//  URLSession+Async.swift
//  JDKUpdater
//
//  Created by Gerrit Grunwald on 05.04.24.
//

import Foundation


extension URLSession {
            
    func data(with url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            dataTask(with: url) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bad Response"]))
                }
            }
            .resume()
        }
    }
    
    func data(with request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bad Response"]))
                }
            }
            .resume()
        }
    }
    
}
