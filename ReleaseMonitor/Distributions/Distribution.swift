//
//  Distribution.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import Foundation

public class Distribution : Codable, Hashable, Equatable {
    public let uiString  : String
    public let apiString : String
    public var latestGA  : VersionNumber?
    public var latestEA  : VersionNumber?
    
    private enum CodingKeys: String, CodingKey {
        case latestGa  = "latest_ga"
        case latestEa  = "latest_ea"
        case uiString  = "ui_string"
        case apiString = "api_string"
    }
    
    
    public init(uiString: String, apiString: String, latestGA: VersionNumber?, latestEA: VersionNumber?) {
        switch apiString {
            case "liberica_native"  : self.uiString = "Liberica NIK"
            case "graalvm_community": self.uiString = "GraalVM CE"
            case "oracle_open_jdk"  : self.uiString = "OpenJDK"
            default                 : self.uiString = uiString
        }
        self.apiString = apiString
        self.latestGA  = latestGA
        self.latestEA  = latestEA
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        apiString = try! container.decode(String.self, forKey: .apiString)
        switch apiString {
            case "liberica_native"  : self.uiString = "Liberica NIK"
            case "graalvm_community": self.uiString = "GraalVM CE"
            case "oracle_open_jdk"  : self.uiString = "OpenJDK"
            default                 : self.uiString = try! container.decode(String.self, forKey: .uiString)
        }
        latestGA  = try? VersionNumber.fromText(text: container.decode(String.self, forKey: .latestGa))
        latestEA  = try? VersionNumber.fromText(text: container.decode(String.self, forKey: .latestEa))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(uiString, forKey: .uiString)
        try? container.encode(apiString, forKey: .apiString)
        try? container.encode(latestGA?.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false), forKey: .latestGa)
        try? container.encode(latestEA?.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: true), forKey: .latestEa)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uiString)
    }
    
    public static func == (lhs: Distribution, rhs: Distribution) -> Bool {
        return lhs.uiString == rhs.uiString
    }
}
