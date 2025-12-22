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
}
