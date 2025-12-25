//
//  UpcomingReleases.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import Foundation


class UpcomingReleases: Codable {
    var dateOfNextRelease    : String?
    var versionOfNextRelease : String?
    var daysUntilNextRelease : Int?
    var dateOfNextUpdate     : String?
    var versionsOfNextUpdate : String?
    var daysUntilNextUpdate  : Int?

    private enum CodingKeys : String, CodingKey {
        case dateOfNextRelease    = "date_of_next_release"
        case versionOfNextRelease = "version_of_next_release"
        case daysUntilNextRelease = "days_until_next_release"
        case dateOfNextUpdate     = "date_of_next_update"
        case versionsOfNextUpdate = "versions_of_next_update"
        case daysUntilNextUpdate  = "days_until_next_update"
    }

    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dateOfNextRelease    = try? container.decode(String.self, forKey: .dateOfNextRelease)
        versionOfNextRelease = try? container.decode(String.self, forKey: .versionOfNextRelease)
        daysUntilNextRelease = try? container.decode(Int.self,    forKey: .daysUntilNextRelease)
        dateOfNextUpdate     = try? container.decode(String.self, forKey: .dateOfNextUpdate)
        versionsOfNextUpdate = try? container.decode(String.self, forKey: .versionsOfNextUpdate)
        daysUntilNextUpdate  = try? container.decode(Int.self,    forKey: .daysUntilNextUpdate)
    }    
    
    init(dateOfNextRelease: String?, versionOfNextRelease: String?, daysUntilnextRelease: Int?, dateOfNextUpdate: String?, versionsOfNextUpdate: String?, daysUntilNextUpdate: Int?) {
        self.dateOfNextRelease    = dateOfNextRelease
        self.versionOfNextRelease = versionOfNextRelease
        self.daysUntilNextRelease = daysUntilnextRelease
        self.dateOfNextUpdate     = dateOfNextUpdate
        self.versionsOfNextUpdate = versionsOfNextUpdate
        self.daysUntilNextUpdate  = daysUntilNextUpdate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(dateOfNextRelease,    forKey: .dateOfNextRelease)
        try? container.encode(versionOfNextRelease, forKey: .versionOfNextRelease)
        try? container.encode(daysUntilNextRelease, forKey: .daysUntilNextRelease)
        try? container.encode(dateOfNextUpdate,     forKey: .dateOfNextUpdate)
        try? container.encode(versionsOfNextUpdate, forKey: .versionsOfNextUpdate)
        try? container.encode(daysUntilNextUpdate,  forKey: .daysUntilNextUpdate)
    }
    
    func getVersionOfNextRelease() -> VersionNumber? { return VersionNumber.fromText(text: self.versionOfNextRelease ?? "")}
    
    func getDateOfNextRelease() -> Date? { return Helper.dateFromISOString(self.dateOfNextRelease ?? "") }
    
    func getVersionsOfNextUpdates() -> [VersionNumber] {
        if let versionsString = self.versionsOfNextUpdate {
            let splittedVersions : [Substring]     = versionsString.split(separator: ",")
            var versions         : [VersionNumber] = []
            for versionString in splittedVersions {
                versions.append(VersionNumber.fromText(text: String(versionString)))
            }
            return versions
        } else {
            return []
        }
    }
    
    func getDateOfNextUpdates() -> Date? { return Helper.dateFromISOString(self.dateOfNextUpdate ?? "") }
}
