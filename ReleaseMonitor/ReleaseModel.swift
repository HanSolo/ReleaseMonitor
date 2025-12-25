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
    
    var networkMonitor      : NetworkMonitor         = NetworkMonitor.shared
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
            if networkMonitor.isConnected {
                self.upcomingReleases = await RestController.fetchUpcomingReleases()
                self.distributions    = await RestController.fetchDistributions()
                
                for vendor in Constants.MARKETPLACE_VENDORS.keys {
                    let versionNumber: VersionNumber? = await RestController.fetchLatestReleasesFromMarketPlace(vendor: vendor)
                    if nil != versionNumber {
                        let uiString : String = Constants.MARKETPLACE_VENDORS[vendor]!
                        self.latestOnMarketPlace[uiString] = versionNumber!
                    }
                }
            } else {
                let nextReleaseWithDate : (VersionNumber, Date) = Helper.calcNextRelease()
                let nextUpdateWithDate  : (VersionNumber, Date) = Helper.calcNextUpdate()
                
                let nextRelease : JDKUpdate = Helper.getNextRelease()
                let nextUpdate  : JDKUpdate = Helper.getNextUpdate()
                
                let dateOfNextRelease    : String = Constants.DF_ISO.string(from: nextReleaseWithDate.1)
                let versionOfNextRelease : String = nextReleaseWithDate.0.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)
                let daysUntilNextRelease : Int    = nextRelease.remainingDays
                let dateOfNextUpdate     : String = Constants.DF_ISO.string(from: nextUpdateWithDate.1)
                let versionsOfNextUpdate : String = nextUpdateWithDate.0.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)
                let daysUntilNextUpdate  : Int    = nextUpdate.remainingDays
                
                let ur : UpcomingReleases = UpcomingReleases(dateOfNextRelease: dateOfNextRelease, versionOfNextRelease: versionOfNextRelease, daysUntilnextRelease: daysUntilNextRelease, dateOfNextUpdate: dateOfNextUpdate, versionsOfNextUpdate: versionsOfNextUpdate, daysUntilNextUpdate: daysUntilNextUpdate)
                self.upcomingReleases.append(ur)
            }
        }
    }
}
