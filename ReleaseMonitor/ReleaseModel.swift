//
//  ReleaseModel.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 23.12.25.
//

import Foundation


@Observable
public class ReleaseModel {
    
    static let shared : ReleaseModel = {
        let instance = ReleaseModel()
        return instance
    }()
    
    var upcomingReleases    : [UpcomingReleases]     = []
    var distributions       : [Distribution]         = []
    var latestOnMarketPlace : [String:VersionNumber] = ["Temurin"    : VersionNumber(feature: 1),
                                                        "Dragonwell" : VersionNumber(feature: 1),
                                                        "Zulu"       : VersionNumber(feature: 1),
                                                        "Semeru"     : VersionNumber(feature: 1),
                                                        "Microsoft"  : VersionNumber(feature: 1),
                                                        "RedHat"     : VersionNumber(feature: 1)]
    
    public func update() -> Void {
        Task {
            self.upcomingReleases = await RestController.fetchUpcomingReleases()
            self.distributions    = await RestController.fetchDistributions()
            
            for vendor in Constants.MARKETPLACE_VENDORS.keys {
                let versionNumber: VersionNumber? = await RestController.fetchLatestReleasesFromMarketPlace(vendor: vendor)
                if nil != versionNumber {
                    let uiString : String = Constants.MARKETPLACE_VENDORS[vendor]!
                    self.latestOnMarketPlace[uiString] = versionNumber!
                }
            }
        }
    }
}
