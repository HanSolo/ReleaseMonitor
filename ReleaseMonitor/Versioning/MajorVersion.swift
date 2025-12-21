//
//  MajorVersion.swift
//  JDKMonitor
//
//  Created by Gerrit Grunwald on 07.10.23.
//

import Foundation


public struct MajorVersion: Codable, Equatable, Sendable, Hashable {
    let majorVersion    : Int
    let termOfSupport   : Constants.TermOfSupport
    let maintained      : Bool
    let earlyAccessOnly : Bool
    let releaseStatus   : Constants.ReleaseStatus
    let versions        : [String]
    
    
    init(majorVersion: Int, termOfSupport: Constants.TermOfSupport, maintained: Bool, earlyAccessOnly: Bool, releaseStatus: Constants.ReleaseStatus, versions: [String]) {
        self.majorVersion    = majorVersion
        self.termOfSupport   = termOfSupport
        self.maintained      = maintained
        self.earlyAccessOnly = earlyAccessOnly
        self.releaseStatus   = releaseStatus
        self.versions        = versions
    }
    
    
    public static func == (lhs: MajorVersion, rhs: MajorVersion) -> Bool {
        return lhs.majorVersion == rhs.majorVersion
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(majorVersion)
    }
}

extension MajorVersion {
    
    enum CodingKeys: String, CodingKey {
        case majorVersion    = "major_version"
        case termOfSupport   = "term_of_support"
        case maintained      = "maintained"
        case earlyAccessOnly = "early_access_only"
        case releaseStatus   = "release_status"
        case versions        = "versions"
    }
    
    public init(from decoder: Decoder) throws {
        let container        = try decoder.container(keyedBy: CodingKeys.self)
        
        self.majorVersion    = try container.decode(Int.self, forKey: .majorVersion)
        self.termOfSupport   = container.contains(.termOfSupport)  ? try container.decode(Constants.TermOfSupportType.self, forKey: .termOfSupport).toTermOfSupport() : Constants.TermOfSupport.not_found
        self.maintained      = container.contains(.maintained)      ? try container.decode(Bool.self, forKey: .maintained)                                   : true
        self.earlyAccessOnly = container.contains(.earlyAccessOnly) ? try container.decode(Bool.self, forKey: .earlyAccessOnly)                              : false
        self.releaseStatus   = container.contains(.releaseStatus)   ? try container.decode(Constants.ReleaseStatusType.self, forKey: .releaseStatus).toReleaseStatus() : Constants.ReleaseStatus.not_found
        self.versions        = container.contains(.versions)        ? try container.decode([String].self, forKey: .versions)                                 : []
    }
    
    public init(majorVersion: MajorVersion) {
        self.majorVersion    = majorVersion.majorVersion
        self.termOfSupport   = majorVersion.termOfSupport
        self.maintained      = majorVersion.maintained
        self.earlyAccessOnly = majorVersion.earlyAccessOnly
        self.releaseStatus   = majorVersion.releaseStatus
        self.versions        = majorVersion.versions        
    }

    
    init(majorVersion: Int, termOfSupport: String, maintained: Bool, earlyAccessOnly: Bool, releaseStatus: String, versions: [String]) {
        self.init(majorVersion: majorVersion, termOfSupport: Constants.TermOfSupportType.string(termOfSupport).toTermOfSupport(), maintained: maintained, earlyAccessOnly: earlyAccessOnly, releaseStatus: Constants.ReleaseStatusType.string(releaseStatus).toReleaseStatus(), versions: versions)
    }
    
}

public struct MajorVersionData: Codable {
    var majorVersion    : Int?
    var termOfSupport   : String?
    var maintained      : Bool?
    var earlyAccessOnly : Bool?
    var releaseStatus   : String?
    var versions        : [String]?
}
