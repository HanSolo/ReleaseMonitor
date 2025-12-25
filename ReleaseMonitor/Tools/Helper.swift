//
//  Helper.swift
//  JavaUpdater
//
//  Created by Gerrit Grunwald on 04.02.24.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications


public struct Helper {
    @Environment(NetworkMonitor.self) var networkMonitor : NetworkMonitor
    private static                    let dateFormatter  : DateFormatter  = DateFormatter()
        
    
    public static func parseMajorVersionJSONEntries(data: Data) -> [MajorVersion]? {
        var majorVersions: [MajorVersion]?
        do {
            let jsonDecoder        = JSONDecoder()
            let dictionaryFromJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            let jsonItem           = dictionaryFromJSON["result"] as? NSArray
            let jsonData           = try JSONSerialization.data(withJSONObject: jsonItem!, options: [])
            majorVersions          = try jsonDecoder.decode([MajorVersion].self, from: jsonData)
        } catch {
            majorVersions = []
        }
        return majorVersions
    }
    
    static func parseUpcomingReleasesJSONEntries(data: Data) -> [UpcomingReleases]? {
        var upcomingReleases     : [UpcomingReleases]    = []
        let upcomingReleasesData : UpcomingReleasesData = try! JSONDecoder().decode(UpcomingReleasesData.self, from: data)
        if let results : [UpcomingReleases] = upcomingReleasesData.result {
            upcomingReleases = results
        }
        return upcomingReleases
    }
    
    static func parseDistributionsJSONEntries(data: Data) -> [Distribution]? {
        var distributions     : [Distribution]    = []
        let distributionData : DistributionData = try! JSONDecoder().decode(DistributionData.self, from: data)
        if let results : [Distribution] = distributionData.result {
            distributions = results
        }
        return distributions
    }
    
    static func parseMarketPlaceReleaseJSONEntries(data: Data) -> VersionNumber? {
        do {
            let jsonString : String = String(data: data, encoding: .utf8)!
            let jsonData   : Data   = Data(jsonString.utf8)
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any] {
                guard let releaseObject  : [String: Any] = json.first as? [String: Any] else { return nil }
                guard let versionObject  : [String: Any] = releaseObject["version"] as? [String: Any] else { return nil }
                guard let openjdkVersion : String        = versionObject["openjdk_version"] as? String else { return nil }
                let versionNumber : VersionNumber = VersionNumber.fromText(text: openjdkVersion)
                return versionNumber
            }
        } catch {
            debugPrint("Error parsong json")
        }
        return nil
    }
    
    public static func index(of text: String, in source: String) -> Int? {
        for (index, _) in source.enumerated() {
            var found = true
            for (offset, char2) in text.enumerated() {
                if source[source.index(source.startIndex, offsetBy: index + offset)] != char2 {
                    found = false
                    break
                }
            }
            if found {
                return index
            }
        }
        return nil
    }
    
    public static func isPositiveInt(text: String) -> Bool {
        if Int(text) != nil {
            return Int(text)! > 0
        } else {
            return false
        }
    }
    
    public static func trimPrefix(text: String, prefix: String) -> String {
        if let range = text.range(of: prefix) {
            return text.replacingCharacters(in: range, with: "")
        } else {
            return text
        }
    }
    
    public static func secondsToHHMMString(seconds: Double) -> String {
        let hhmmss : (Int, Int) = secondsToHHMM(seconds: seconds)
        return String(format:"%02d:%02d", hhmmss.0, hhmmss.1)
    }
    public static func secondsToHHMM(seconds: Double) -> (Int, Int) {
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3600.0)).truncatingRemainder(dividingBy: 24.0))
        return ( hours, minutes )
    }
    
    public static func secondsToHHMMSSString(seconds: Double) -> String {
        let hhmmss : (Int, Int, Int) = secondsToHHMMSS(seconds: seconds)
        return String(format:"%02d:%02d:%02d", hhmmss.0, hhmmss.1, hhmmss.2)
    }
    public static func secondsToHHMMSS(seconds: Double) -> (Int, Int, Int) {
        let secs    : Int = Int(seconds.truncatingRemainder(dividingBy: 60))
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3600.0)).truncatingRemainder(dividingBy: 24.0))
        return ( hours, minutes, secs )
    }
    
    public static func getNumberOfWeekdaysIn(weekday: Int, month: Int, year: Int) -> Int {
        let calendar       : Calendar       = Calendar.current
        var dateComponents : DateComponents = DateComponents(year: year, month: month, day: 1)
        let date           : Date           = calendar.date(from: dateComponents)!
        let daysInMonth    : Int            = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        var daysFound      : Int            = 0
        for day in 1..<daysInMonth {
            dateComponents.day = day
            let tmpDate = calendar.date(from: dateComponents)!
            if calendar.component(.weekday, from: tmpDate) == weekday {
                daysFound += 1
            }
        }
        return daysFound
    }
    
    public static func dateFromISOString(_ isoString: String) -> Date? {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withFullDate]
        return isoDateFormatter.date(from: isoString)
    }
    
    public static func getNextRelease() -> JDKUpdate { return getNextRelease(from: Date()) }
    public static func getNextRelease(from: Date) -> JDKUpdate {
        let date = Calendar.current.dateComponents([.year], from: from)
        
        var components = DateComponents()
        
        components.year  = date.year
        components.month = 3
        components.day   = 1
        let updateMarch : Date = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        
        components.month = 9
        components.day   = 1
        let updateSeptember : Date = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        
        components.year  = date.year! + 1
        components.month = 3
        components.day   = 1
        let updateNextMarch : Date = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        
        
        let daysToUpdateMarch     = Calendar.current.dateComponents([.day], from: from, to: updateMarch)
        let daysToUpdateSeptember = Calendar.current.dateComponents([.day], from: from, to: updateSeptember)
        let daysToUpdateNextMarch = Calendar.current.dateComponents([.day], from: from, to: updateNextMarch)
        
        var remainingDays : [Date:Int] = [:]
        remainingDays[updateMarch]     = daysToUpdateMarch.day
        remainingDays[updateSeptember] = daysToUpdateSeptember.day
        remainingDays[updateNextMarch] = daysToUpdateNextMarch.day
        
        let sorted = remainingDays.filter { $0.value >= 0 }.sorted { $0.1 < $1.1 }
        
        return JDKUpdate(date: sorted.first!.key, remainingDays: sorted.first!.value + 1, type: Constants.UpdateType.release)
    }
    
    public static func getNextUpdate() -> JDKUpdate { return getNextUpdate(from: Date()) }
    public static func getNextUpdate(from: Date) -> JDKUpdate {
        let date       = Calendar.current.dateComponents([.year], from: from)
        var components = DateComponents()
        
        // 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
        components.year  = date.year
        components.month = 1
        components.day   = 1
        let updateJanuary : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.month = 4
        components.day   = 1
        let updateApril : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateApril = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateApril = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.month = 7
        components.day   = 1
        let updateJuly : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateJuly = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateJuly = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.month = 10
        components.day   = 1
        let updateOctober : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateOctober = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateOctober = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.year  = date.year! + 1
        components.month = 1
        components.day   = 1
        let updateNextJanuary : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateNextJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateNextJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        
        let daysToUpdateJanuary     = Calendar.current.dateComponents([.day], from: from, to: updateJanuary)
        let daysToUpdateApril       = Calendar.current.dateComponents([.day], from: from, to: updateApril)
        let daysToUpdateJuly        = Calendar.current.dateComponents([.day], from: from, to: updateJuly)
        let daysToUpdateOctober     = Calendar.current.dateComponents([.day], from: from, to: updateOctober)
        let daysToUpdateNextJanuary = Calendar.current.dateComponents([.day], from: from, to: updateNextJanuary)
        
        var remainingDays : [Date:Int]   = [:]
        remainingDays[updateJanuary]     = daysToUpdateJanuary.day
        remainingDays[updateApril]       = daysToUpdateApril.day
        remainingDays[updateJuly]        = daysToUpdateJuly.day
        remainingDays[updateOctober]     = daysToUpdateOctober.day
        remainingDays[updateNextJanuary] = daysToUpdateNextJanuary.day
        
        let sorted = remainingDays.filter { $0.value >= 0 }.sorted { $0.1 < $1.1 }
        
        return JDKUpdate(date: sorted.first!.key, remainingDays: sorted.first!.value + 1, type: Constants.UpdateType.release)
    }
    
    public static func calcNextRelease() -> (VersionNumber,Date) {
        let now             : Date = Date()
        var nextReleaseDate : Date = Constants.JDK_24_RELEASE_DATE
        var nextRelease     : Int    = 24
        var jdkUpdate       : JDKUpdate = getNextRelease(from: nextReleaseDate)
        for i in 25...Int.max {
            jdkUpdate       = getNextRelease(from: nextReleaseDate.dayAfter)
            nextReleaseDate = jdkUpdate.date
            nextRelease     = i
            if (nextReleaseDate >= now) { break; }
        }        
        return (VersionNumber(feature: nextRelease), nextReleaseDate)
    }
    public static func calcNextUpdate() -> (VersionNumber,Date) {
        let now             : Date      = Date()
        var nextUpdateDate  : Date      = Constants.JDK_23_RELEASE_DATE
        var nextUpdate      : Int       = 23
        var jdkUpdate       : JDKUpdate = getNextUpdate(from: nextUpdateDate)
        var updateVersion   : Int       = 0
        for _ in 24...Int.max {
                jdkUpdate       = getNextUpdate(from: nextUpdateDate.dayAfter)
                nextUpdateDate  = jdkUpdate.date
                updateVersion   += 1
                if updateVersion == 3 {
                    updateVersion =  1
                    nextUpdate    += 1
                }
                if (nextUpdateDate >= now) { break }
        }
        return( VersionNumber(feature: nextUpdate, interim: 0, update: updateVersion), nextUpdateDate)
    }
    
    public static func isSTS(featureVersion: Int) -> Bool {
        if featureVersion < 9 { return false }
        switch featureVersion {
        case 9, 10 : return true
        default    : return !isLTS(featureVersion: featureVersion)
        }
    }
    
    public static func isMTS(featureVersion: Int) -> Bool {
        if featureVersion < 13 { return false }
        return !isLTS(featureVersion: featureVersion) && Double(featureVersion).truncatingRemainder(dividingBy: 2) != 0
    }
    
    public static func isLTS(featureVersion: Int) -> Bool {
        if featureVersion < 1  { return false }
        if featureVersion <= 8 { return true }
        if featureVersion < 11 { return false }
        if featureVersion < 17 { return ((Double(featureVersion) - 11.0) / 6.0).truncatingRemainder(dividingBy: 1) == 0 }
        return ((Double(featureVersion) - 17.0) / 4.0).truncatingRemainder(dividingBy: 1) == 0
    }
}
