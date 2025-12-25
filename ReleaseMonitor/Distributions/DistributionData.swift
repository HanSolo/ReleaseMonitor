//
//  DistributionData.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 22.12.25.
//

import Foundation


class DistributionData: Codable {
    var result  : [Distribution]?
    var message : String?

    
    private enum CodingKeys: String, CodingKey {
        case result = "result"
        case message = "message"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result  = try? container.decode([Distribution].self, forKey: .result)
        message = try? container.decode(String.self,   forKey: .message)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(result,  forKey: .result)
        try? container.encode(message, forKey: .message)
    }
}
