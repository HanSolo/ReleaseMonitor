//
//  ReleaseModel.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 23.12.25.
//

import Foundation
import Observation


@Observable
public class ReleaseModel {
    
    static let shared : ReleaseModel = {
        let instance = ReleaseModel()
        return instance
    }()
    
    var networkMonitor      : NetworkMonitor                 = NetworkMonitor.shared
    var discoApiAvailable   : Bool                           = true
    var lastRelease         : Int                            = Helper.calcLastRelease().0.feature ?? 0
    var nextRelease         : Int                            = Helper.calcNextRelease().0.feature ?? 0
    var upcomingReleases    : [UpcomingReleases]             = []
    var distributions       : [Distribution]                 = [] {
        didSet {
            Task {
                for distribution in self.distributions {
                    let ltsReleases : [VersionNumber] = await RestController.fetchLTSVersionsForDistribution(distribution: distribution)
                    self.ltsReleases[distribution] = ltsReleases
                    if distribution.apiString == "zulu", !ltsReleases.isEmpty {
                        for ltsRelease in ltsReleases {
                            if self.ltsReleasesAsInt.contains(ltsRelease.feature!) { continue }
                            self.ltsReleasesAsInt.append(ltsRelease.feature!)
                        }
                    }
                }
            }
        }
    }
    var ltsReleases         : [Distribution:[VersionNumber]] = [:]
    var ltsReleasesAsInt    : [Int]                          = []
    var selectedLtsRelease  : Int                            = 25
    var latestOnMarketPlace : [String:VersionNumber]         = ["Temurin"    : VersionNumber(feature: 1),
                                                                "Dragonwell" : VersionNumber(feature: 1),
                                                                "Zulu"       : VersionNumber(feature: 1),
                                                                "Semeru"     : VersionNumber(feature: 1),
                                                                "Microsoft"  : VersionNumber(feature: 1),
                                                                "RedHat"     : VersionNumber(feature: 1)]
    
    private init() {
        Timer.scheduledTimer(withTimeInterval: Constants.UPDATE_CHECK_INTERVAL, repeats: true) { timer in
            Task {
                let available = await RestController.checkApiAvailability()
                await MainActor.run {
                    self.discoApiAvailable = available
                }
            }
            
            let now        : Double = Date.init().timeIntervalSince1970
            let lastUpdate : Double = Properties.instance.lastUpdate!
                                                
            if now - lastUpdate > Constants.UPDATE_INTERVAL && self.networkMonitor.isOnline {
                Task.detached {
                    await self.update()
                }
            }
        }
        
        // Initial update
        if self.networkMonitor.isOnline {
            Task.detached {
                await self.update()
            }
        }
    }
    
    @MainActor public func update() async -> Void {
        Task {
            self.lastRelease = Helper.calcLastRelease().0.feature ?? 0
            self.nextRelease = Helper.calcNextRelease().0.feature ?? 0
            
            if networkMonitor.isConnected {
                if await RestController.checkApiAvailability() {
                    self.discoApiAvailable = true
                    self.upcomingReleases  = await RestController.fetchUpcomingReleases()
                    self.distributions     = await RestController.fetchDistributions()
                    
                    for vendor in Constants.MARKETPLACE_VENDORS.keys {
                        let versionNumber: VersionNumber? = await RestController.fetchLatestReleasesFromMarketPlace(vendor: vendor)
                        if nil != versionNumber {
                            let uiString : String = Constants.MARKETPLACE_VENDORS[vendor]!
                            self.latestOnMarketPlace[uiString] = versionNumber!
                        }
                    }
                } else {
                    self.discoApiAvailable = false
                }
            } else {
                // Next release
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
                
                
                /* Last release
                let lastReleaseWithDate : (VersionNumber, Date) = Helper.calcLastRelease()
                let lastUpdateWithDate  : (VersionNumber, Date) = Helper.calcLastUpdate()
                
                let lastRelease : JDKUpdate = Helper.getLastRelease()
                let lastUpdate  : JDKUpdate = Helper.getLastUpdate()
            
                let dateOfLastRelease    : String = Constants.DF_ISO.string(from: lastReleaseWithDate.1)
                let versionOfLastRelease : String = lastReleaseWithDate.0.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)
                let daysSinceLastRelease : Int    = lastRelease.remainingDays
                let dateOfLastUpdate     : String = Constants.DF_ISO.string(from: lastUpdateWithDate.1)
                let versionsOfLastUpdate : String = lastUpdateWithDate.0.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)
                let daysSinceLastUpdate  : Int    = lastUpdate.remainingDays
                */
            }
        }
    }
}
