//
//  NetworkingError.swift
//  JDKUpdater
//
//  Created by Gerrit Grunwald on 28.11.24.
//

import Foundation


enum NetworkingError: Error {
    case encodingFailed(innerError: EncodingError)
    case decodingFailed(innerError: DecodingError)
    case invalidStatusCode(statusCode: Int)
    case requestFailed(innerError: URLError)
    case otherError(innerError: Error)
}
