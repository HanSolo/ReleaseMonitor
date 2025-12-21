//
//  Update.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import Foundation


public class Update {
    public let distribution       : Distribution
    public var lastUpdateLatestGA : Date
    public var lastUpdateLatestEA : Date
    
    
    init(distribution: Distribution, lastUpdateLatestGA: Date, lastUpdateLatestEA: Date) {
        self.distribution       = distribution
        self.lastUpdateLatestGA = lastUpdateLatestGA
        self.lastUpdateLatestEA = lastUpdateLatestEA
    }
    
    
    public func wasLatestGAUpdateToday() -> Bool {
        let now : Date = Date.now
        return now.day   == self.lastUpdateLatestGA.day &&
               now.month == self.lastUpdateLatestGA.month &&
               now.year  == self.lastUpdateLatestGA.year
    }
    public func wasLatestEAUpdateToday() -> Bool {
        let now : Date = Date.now
        return now.day   == self.lastUpdateLatestEA.day &&
               now.month == self.lastUpdateLatestEA.month &&
               now.year  == self.lastUpdateLatestEA.year
    }
    
}
