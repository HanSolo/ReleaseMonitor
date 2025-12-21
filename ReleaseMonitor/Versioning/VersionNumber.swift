//
//  VersionNumber.swift
//  JDKMonitor
//
//  Created by Gerrit Grunwald on 09.10.23.
//

import Foundation


public final class VersionNumber : Comparable, Hashable, Codable, Sendable {
    public static let VERSION_NO_PATTERN      = /([1-9]\d*)((u(\d+))|(\.?(\d+)?\.?(\d+)?\.?(\d+)?\.?(\d+)?\.(\d+)))?(([_b])(\d+))?(((\+|\-)([a-zA-Z0-9_]+))?((\+|\-)([a-zA-Z0-9_]+))?)?/
    public static let BUILD_PATTERN           = /\d+/
    public static let BUILD_NUMBER_PATTERN    = /\+?([bB])([0-9]+)/
    public static let LEADING_INT_PATTERN     = /^[0-9]*/
    public        var feature                 : Int? {
        willSet {
            assert(newValue ?? 1 >= 0)
        }
    }
    public        var interim                 : Int? {
        willSet {
            assert(newValue! >= 0)
        }
    }
    public        var update                  : Int? {
        willSet {
            assert(newValue! >= 0)
        }
    }
    public        var patch                   : Int? {
        willSet {
            assert(newValue! >= 0)
        }
    }
    public        var fifth                   : Int? {
        willSet {
            assert(newValue! >= 0)
        }
    }
    public        var sixth                   : Int? {
        willSet {
            assert(newValue! >= 0)
        }
    }
    public        var build                   : Int? {
        willSet {
            assert(newValue! >= 0)
        }
    }
    public        var releaseStatus           : Constants.ReleaseStatus?
        
    
    init(feature: Int? = 1, interim: Int? = 0, update: Int? = 0, patch: Int? = 0, fifth: Int? = 0, sixth: Int? = 0, build: Int? = 0, releaseStatus: Constants.ReleaseStatus? = nil) {
        self.feature       = feature       != nil && 0 >= feature! ? 1   : feature!
        self.interim       = interim       != nil && 0 > interim!  ? 0   : interim!
        self.update        = update        != nil && 0 > update!   ? 0   : update!
        self.patch         = patch         != nil && 0 > patch!    ? 0   : patch!
        self.fifth         = fifth         != nil && 0 > fifth!    ? 0   : fifth!
        self.sixth         = sixth         != nil && 0 > sixth!    ? 0   : sixth!
        self.build         = build         != nil && 0 > build!    ? 0   : build!
        self.releaseStatus = releaseStatus == nil                  ? nil : releaseStatus!
    }
    
    public func compareTo(otherVersionNumber: VersionNumber) -> Int {
        let equal       : Int = 0
        let smallerThan : Int = -1
        let largerThan  : Int = 1
        var ret         : Int
            
        if feature! > otherVersionNumber.feature! {
            ret = largerThan
        } else if feature! < otherVersionNumber.feature! {
            ret = smallerThan
        } else {
            if interim != nil && otherVersionNumber.interim != nil {
                if interim! > otherVersionNumber.interim! {
                    ret = largerThan
                } else if interim! < otherVersionNumber.interim! {
                    ret = smallerThan
                } else {
                    if update != nil && otherVersionNumber.update != nil {
                        if update! > otherVersionNumber.update! {
                            ret = largerThan
                        } else if update! < otherVersionNumber.update! {
                            ret = smallerThan
                        } else {
                            if patch != nil && otherVersionNumber.patch != nil {
                                if patch! > otherVersionNumber.patch! {
                                    ret = largerThan
                                } else if patch! < otherVersionNumber.patch! {
                                    ret = smallerThan
                                } else {
                                    if fifth != nil && otherVersionNumber.fifth != nil {
                                        if fifth! > otherVersionNumber.fifth! {
                                            ret = largerThan
                                        } else if fifth! < otherVersionNumber.fifth! {
                                            ret = smallerThan
                                        } else {
                                            if sixth != nil && otherVersionNumber.sixth != nil {
                                                if sixth! > otherVersionNumber.sixth! {
                                                    ret = largerThan
                                                } else if sixth! < otherVersionNumber.sixth! {
                                                    ret = smallerThan
                                                } else {
                                                    let thisStatus  : Constants.ReleaseStatus = self.releaseStatus != nil ? self.releaseStatus! : Constants.ReleaseStatus.ga
                                                    let otherStatus : Constants.ReleaseStatus = otherVersionNumber.releaseStatus != nil ? otherVersionNumber.releaseStatus! : Constants.ReleaseStatus.ga

                                                    if Constants.ReleaseStatus.ga == thisStatus && Constants.ReleaseStatus.ea == otherStatus {
                                                        ret = largerThan
                                                    } else if Constants.ReleaseStatus.ea == thisStatus && Constants.ReleaseStatus.ga == otherStatus {
                                                        ret = smallerThan
                                                    } else if thisStatus == otherStatus {
                                                        // Either both GA or both EA
                                                        let thisBuild  : Int = self.build               != nil ? self.build!               : 0
                                                        let otherBuild : Int = otherVersionNumber.build != nil ? otherVersionNumber.build! : 0

                                                        ret = thisBuild == otherBuild ? equal : thisBuild < otherBuild ? smallerThan : largerThan
                                                    } else {
                                                        ret = equal
                                                    }
                                                }
                                            } else if sixth != nil && otherVersionNumber.sixth != nil {
                                                ret = largerThan
                                            } else if sixth == nil && otherVersionNumber.sixth != nil {
                                                ret = smallerThan
                                            } else {
                                                ret = equal
                                            }
                                        }
                                    } else if fifth != nil && otherVersionNumber.fifth == nil {
                                        ret = largerThan
                                    } else if fifth == nil && otherVersionNumber.fifth != nil {
                                        ret = smallerThan
                                    } else {
                                        ret = equal
                                    }
                                }
                            } else if patch != nil && otherVersionNumber.patch == nil {
                                ret = largerThan
                            } else if patch == nil && otherVersionNumber.patch != nil {
                                ret = smallerThan
                            } else {
                                ret = equal
                            }
                        }
                    } else if update != nil && otherVersionNumber.update == nil {
                        ret = largerThan
                    } else if update == nil && otherVersionNumber.update != nil {
                        ret = smallerThan
                    } else {
                        ret = equal
                    }
                }
            } else if self.interim != nil && otherVersionNumber.interim == nil {
                ret = largerThan
            } else if self.interim == nil && otherVersionNumber.interim != nil {
                ret = smallerThan
            } else {
                ret = equal
            }
        }
        
        if ret == equal {
            if self.releaseStatus != nil && Constants.ReleaseStatus.ea == self.releaseStatus && self.build != nil &&
                otherVersionNumber.releaseStatus != nil && Constants.ReleaseStatus.ea == otherVersionNumber.releaseStatus! && otherVersionNumber.build != nil {
                let buildNumber      : Int = self.build!
                let otherBuildNumber : Int = otherVersionNumber.build!
                ret = buildNumber == otherBuildNumber ? equal : buildNumber < otherBuildNumber ? smallerThan : largerThan
            } else if self.releaseStatus != nil && Constants.ReleaseStatus.ea == self.releaseStatus! && self.build != nil && otherVersionNumber.releaseStatus != nil && Constants.ReleaseStatus.ea == otherVersionNumber.releaseStatus! && otherVersionNumber.build == nil {
                ret = largerThan
            } else if self.releaseStatus != nil && Constants.ReleaseStatus.ea == self.releaseStatus! && self.build == nil &&
                        otherVersionNumber.releaseStatus != nil && Constants.ReleaseStatus.ea == otherVersionNumber.releaseStatus! && otherVersionNumber.build != nil {
                ret = smallerThan
            }
        }
        return ret
    }
    
    public func isSmallerThan(versionNumber: VersionNumber) -> Bool {
        return self.compareTo(otherVersionNumber: versionNumber) < 0
    }
    public func isSmallerOrEqualThan(versionNumber: VersionNumber) -> Bool {
        return self.compareTo(otherVersionNumber: versionNumber) <= 0
    }
    public func isGreaterOrEqualThan(versionNumber: VersionNumber) -> Bool {
        return self.compareTo(otherVersionNumber: versionNumber) >= 0
    }
    public func isGreaterThan(versionNumber: VersionNumber) -> Bool {
        return self.compareTo(otherVersionNumber: versionNumber) > 0
    }
    
    
    public func equals(other: VersionNumber) -> Bool {
        if other.feature == 0 { return false }
        var isEqual : Bool
        if feature == other.feature {
            if interim != nil {
                if other.interim != nil {
                    if interim! == other.interim! {
                        if update != nil {
                            if other.update != nil {
                                if update! == other.update! {
                                    if patch != nil {
                                        if other.patch != nil {
                                            if patch! == other.patch! {
                                                if fifth != nil {
                                                    if other.fifth != nil {
                                                        if fifth! == other.fifth! {
                                                            if sixth != nil {
                                                                if other.sixth != nil {
                                                                    isEqual = sixth! == other.sixth!
                                                                } else {
                                                                    isEqual = false
                                                                }
                                                            } else {
                                                                isEqual = true
                                                            }
                                                        } else {
                                                            isEqual = false
                                                        }
                                                    } else {
                                                        isEqual = false
                                                    }
                                                } else {
                                                    isEqual = true
                                                }
                                            } else {
                                                isEqual = false
                                            }
                                        } else {
                                            isEqual = false
                                        }
                                    } else {
                                        isEqual = true
                                    }
                                } else {
                                    isEqual = false
                                }
                            } else {
                                isEqual = false
                            }
                        } else {
                            isEqual = true
                        }
                    } else {
                        isEqual = false
                    }
                } else {
                    isEqual = false
                }
            } else {
                isEqual = true
            }
        } else {
            isEqual = false
        }
        if isEqual && self.releaseStatus != nil && Constants.ReleaseStatus.ea == self.releaseStatus! && self.build != nil &&
            other.releaseStatus != nil && Constants.ReleaseStatus.ea == other.releaseStatus! && other.build != nil {
            isEqual = build! == other.build!
        }
        if self.releaseStatus != other.releaseStatus {
            isEqual = false
        }
        return isEqual
    }
    public static func equalsExceptBuild(v1: VersionNumber, v2: VersionNumber) -> Bool { return v1.equals(other: v2) }
    public static func equalsIncludingBuild(v1: VersionNumber, v2: VersionNumber) -> Bool { return v1.compareTo(otherVersionNumber: v2) == 0 }
    
    public static func ==(v1: VersionNumber, v2: VersionNumber) -> Bool {
        return v1.compareTo(otherVersionNumber: v2) == 0
    }
    public static func <(v1: VersionNumber, v2: VersionNumber) -> Bool {
        return v1.isSmallerThan(versionNumber: v2)
    }
    public static func <=(v1: VersionNumber, v2: VersionNumber) -> Bool {
        return v1.isSmallerOrEqualThan(versionNumber: v2)
    }
    public static func >=(v1: VersionNumber, v2: VersionNumber) -> Bool {
        return v1.isGreaterOrEqualThan(versionNumber: v2)
    }
    public static func >(v1: VersionNumber, v2: VersionNumber) -> Bool {
        return v1.isGreaterThan(versionNumber: v2)
    }
    
    public func isGreaterThanIgnoreBuild(versionNumber: VersionNumber) -> Bool {
        if self.compareTo(otherVersionNumber: versionNumber) > 0 {
            if feature! == versionNumber.feature! &&
               interim! == versionNumber.interim! &&
               update!  == versionNumber.update!  &&
               patch!   == versionNumber.patch! {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    public func toNormalizedVersionNumber(javaFormat: Bool) -> String {
        var versionBuilder : String = ""
        versionBuilder += "\(self.feature  != nil ? "\(self.feature!)" : "1")"
        versionBuilder += ".\(self.interim != nil ? "\(self.interim!)" : "0")"
        versionBuilder += ".\(self.update  != nil ? "\(self.update!)"  : "0")"
        versionBuilder += ".\(self.patch   != nil ? "\(self.patch!)"   : "0")"
        if !javaFormat {
            versionBuilder += ".\(self.fifth   != nil ? "\(self.fifth!)"   : "0")"
            versionBuilder += ".\(self.sixth   != nil ? "\(self.sixth!)"   : "0")"
        }
        return versionBuilder
    }
    
    public func toString() -> String {
        return toString(outputFormat: Constants.OutputFormat.full, javaFormat: true, includeReleaseStatusAndBuild: true)
    }
    public func toString(outputFormat: Constants.OutputFormat, javaFormat: Bool, includeReleaseStatusAndBuild: Bool) -> String {
        let pre   = self.releaseStatus != nil ? Constants.ReleaseStatus.ea == self.releaseStatus! ? "-ea" : "" : ""
        let build = (self.build != nil && self.build! > 0) ? ("+\(self.build!)") : ""

        var versionBuilder : String = ""
        switch outputFormat {
            case .reduced           : fallthrough
            case .reduced_compressed:
                versionBuilder += self.feature != nil ? "\(self.feature!)" : "1"
                
                if self.sixth != nil && self.sixth! != 0 {
                    if self.interim != nil { versionBuilder += ".\(self.interim!)" }
                    if self.update  != nil { versionBuilder += ".\(self.update!)"  }
                    if self.patch   != nil { versionBuilder += ".\(self.patch!)"   }
                    if !javaFormat {
                        if self.fifth != nil { versionBuilder += ".\(self.fifth!)" }
                        versionBuilder += ".\(self.sixth!)"
                    }
                    if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                    return versionBuilder
                } else if self.fifth != nil && self.fifth! != 0 {
                    if self.interim != nil { versionBuilder += ".\(self.interim!)" }
                    if self.update  != nil { versionBuilder += ".\(self.update!)"  }
                    if self.patch   != nil { versionBuilder += ".\(self.patch!)"   }
                    if !javaFormat { versionBuilder += ".\(self.fifth!)" }
                    if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                    return versionBuilder
                } else if self.patch != nil && self.patch! != 0 {
                    if self.interim != nil { versionBuilder += ".\(self.interim!)" }
                    if self.update  != nil { versionBuilder += ".\(self.update!)"  }
                    versionBuilder += ".\(self.patch!)"
                    if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                    return versionBuilder
                } else if self.update != nil && self.update! != 0 {
                    if self.interim != nil { versionBuilder += ".\(self.interim!)" }
                    versionBuilder += ".\(self.update!)"
                    if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                    return versionBuilder
                } else if self.interim != nil && self.interim! != 0 {
                    versionBuilder += ".\(self.interim!)"
                    if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                    return versionBuilder
                } else {
                    if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                    return versionBuilder
                }
            default:                
                versionBuilder += self.feature != nil ? "\(self.feature!)" : "1"
                if self.interim != nil { versionBuilder += ".\(self.interim!)" }
                if self.update  != nil { versionBuilder += ".\(self.update!)"  }
                if self.patch   != nil { versionBuilder += ".\(self.patch!)"   }
                if !javaFormat {
                    if self.fifth != nil { versionBuilder += ".\(self.fifth!)" }
                    if self.sixth != nil { versionBuilder += ".\(self.sixth!)" }
                }
                if includeReleaseStatusAndBuild { versionBuilder += "\(pre)\(build)" }
                return versionBuilder
            }
    }
        
    public static func fromText(text: String) -> VersionNumber {
        if text.isEmpty {
            //throw Err.invalidParameter(msg: "No version number can be parsed because given text is null or empty.")
            return VersionNumber(feature: 1)
        }
        
        // Remove things like cpu architecture, operating system and file endings
        var tmp : String = text
        for archiveType in Constants.ArchiveType.allCases {
            if !archiveType.fileEnding.isEmpty {
                tmp = tmp.replaceAll(of: archiveType.fileEnding, with: "")
            }
        }
        
        for operatingSystem in Constants.OperatingSystem.allCases {
            for acronym in Constants.OperatingSystem.acronyms(operatingSystem: operatingSystem) {
                if !acronym.isEmpty {
                    tmp = tmp.replaceAll(of: "-\(acronym)", with: "")
                    tmp = tmp.replaceAll(of: "_\(acronym)", with: "")
                }
            }
        }
        
        for architecture in Constants.Architecture.allCases {
            for acronym in Constants.Architecture.acronyms(architecture: architecture) {
                if !acronym.isEmpty {
                    tmp = tmp.replaceAll(of: "-\(acronym)", with: "")
                    tmp = tmp.replaceAll(of: "_\(acronym)", with: "")
                }
            }
        }
                
        // Streamline text to be more compatible to semver by replacing comming findings e.g. .bN -> +bN
        tmp = tmp.replacing(/\-beta/,             with: "-ea")
        tmp = tmp.replacing(/\-BETA/,             with: "-ea")
        tmp = tmp.replacing(/_ea/,                with: "-ea")
        tmp = tmp.replacing(/_b/,                 with: "+b")
        tmp = tmp.replacing(/\-b/,                with: "+b")
        tmp = tmp.replacing(/\.b/,                with: "+b")
        tmp = tmp.replacing(/([0-9])b/,           with: "$1+b")
        tmp = tmp.replacing(/(ea|EA)\.([0-9]+)$/, with: "ea+b$2")
        tmp = tmp.replacing(/\-([0-9]+)$/,        with: "+$1")
        tmp = tmp.replacing(/_openj9.*/,          with: "")
        tmp = tmp.replacing(/\-openj9.*/,         with: "")
        tmp = tmp.replacing(/\-LTS|\-lts/,        with: "")
        
        //print("text    : \(text)")
        //print("stripped: \(tmp)")
        
        
        // Remove leading "1." to get correct version number e.g. 1.8u262 -> 8u262
        let version : String = tmp.starts(with: "1.") ? tmp.replacingOccurrences(of: "1.", with: "") : tmp
                        
        let versionNumber : VersionNumber = VersionNumber(feature: 1)
        if let result = version.firstMatch(of: VERSION_NO_PATTERN) {
            versionNumber.feature = Int(result.1) ?? 0
            
            if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.9 != nil) && (result.10 != nil) && (result.11 != nil) && (result.12 != nil) && (result.13 != nil) && (result.14 != nil) && (result.15 != nil) {
                versionNumber.interim = Int(result.6!) ?? 0
                versionNumber.update  = Int(result.7!) ?? 0
                versionNumber.patch   = Int(result.9!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.10 != nil) && (result.11 != nil) && (result.12 != nil) && (result.13 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.8 != nil) && (result.9 != nil) && (result.10 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.8!)  ?? 0
                versionNumber.fifth   = Int(result.9!)  ?? 0
                versionNumber.sixth   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.8 != nil) && (result.10 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.8!)  ?? 0
                versionNumber.fifth   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.10 != nil) && (result.11 != nil) && (result.12 != nil) && (result.13 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.10!) ?? 0
                versionNumber.update  = Int(result.13!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.10 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.10 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.10 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.8 != nil) && (result.9 != nil) && (result.10 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.8!)  ?? 0
                versionNumber.fifth   = Int(result.9!)  ?? 0
                versionNumber.sixth   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.8 != nil) && (result.10 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.8!)  ?? 0
                versionNumber.fifth   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.3 != nil) && (result.4 != nil) && (result.14 != nil) && (result.15 != nil) && (result.16 != nil) {
                versionNumber.interim = 0
                versionNumber.update = Int(result.4!) ?? 0
            } else if (result.2 != nil) && (result.3 != nil) && (result.4 != nil) && (result.11 != nil) && (result.12 != nil) && (result.13 != nil) {
                versionNumber.interim = 0
                versionNumber.update  = Int(result.4!) ?? 0
            } else if (result.6 != nil) && (result.7 != nil) && (result.10 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.10 != nil) && (result.11 != nil) && (result.12 != nil) && (result.13 != nil) {
                versionNumber.interim = 0
                versionNumber.update  = Int(result.13!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.7 != nil) && (result.10 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.7!)  ?? 0
                versionNumber.patch   = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.6 != nil) && (result.10 != nil) {
                versionNumber.interim = Int(result.6!)  ?? 0
                versionNumber.update  = Int(result.10!) ?? 0
            } else if (result.2 != nil) && (result.3 != nil) && (result.4 != nil) {
                versionNumber.interim = 0
                versionNumber.update  = Int(result.4!) ?? 0
            } else if (result.2 != nil) && (result.5 != nil) && (result.10 != nil) {
                versionNumber.interim = Int(result.10!) ?? 0
            }
            
            // Parse release status and build
            versionNumber.releaseStatus = Constants.ReleaseStatus.ga
            if nil == result.15 && nil == result.18 {
                versionNumber.releaseStatus = Constants.ReleaseStatus.ga
            } else if nil != result.15 && nil == result.18 {
                // Group 15 is present
                if result.16! == "-" {
                    // Early Access
                    versionNumber.releaseStatus = Constants.ReleaseStatus.ea
                } else {
                    // Build
                    if let buildResult = result.17!.firstMatch(of: BUILD_PATTERN) {
                        if !buildResult.0.isEmpty {
                            let build : Int = Int(buildResult.0)!
                            versionNumber.build = build
                        }
                    }
                }
            } else if nil == result.15 && nil != result.18 {
                // Group 18 is present
                if result.19! == "-" {
                    // Early Access
                    versionNumber.releaseStatus = Constants.ReleaseStatus.ea
                } else {
                    // Build
                    if let buildResult = result.20!.firstMatch(of: BUILD_PATTERN) {
                        if !buildResult.0.isEmpty {
                            let build : Int = Int(buildResult.0)!
                            versionNumber.build = build
                        }
                    }
                }
            } else {
                // Group 15 and 18 are present
                if result.16! == "-" {
                    // Early Access
                    versionNumber.releaseStatus = Constants.ReleaseStatus.ea
                } else {
                    // Build
                    if let buildResult = result.17!.firstMatch(of: BUILD_PATTERN) {
                        if !buildResult.0.isEmpty {
                            let build : Int = Int(buildResult.0)!
                            versionNumber.build = build
                        }
                    }
                }
                if result.19! == "-" {
                    // Early Access
                    versionNumber.releaseStatus = Constants.ReleaseStatus.ea
                } else {
                    // Build
                    if let buildResult = result.20!.firstMatch(of: BUILD_PATTERN) {
                        if !buildResult.0.isEmpty {
                            let build : Int = Int(buildResult.0)!
                            versionNumber.build = build
                        }
                    }
                }
            }
            
            // No Semver build found, try things like "b01" etc.
            if versionNumber.build == 0 {
                if let eaBuildNumberResult = version.firstMatch(of: BUILD_NUMBER_PATTERN) {
                    versionNumber.build = Int(eaBuildNumberResult.2) ?? 0
                }
            }

            if versionNumber.interim == nil {
                versionNumber.interim = 0
            }
            if versionNumber.update == nil {
                versionNumber.update = 0
            }
            if versionNumber.patch == nil {
                versionNumber.patch = 0
            }
            if versionNumber.fifth == nil {
                versionNumber.fifth = 0
            }
            if versionNumber.sixth == nil {
                versionNumber.sixth = 0
            }
        }
        
        return versionNumber
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toString(outputFormat: Constants.OutputFormat.full, javaFormat: true, includeReleaseStatusAndBuild: true))
    }
    
    /*
    static func == (lhs: VersionNumber, rhs: VersionNumber) -> Bool {
        return lhs.toString(outputFormat: Constants.OutputFormat.full, javaFormat: true, includeReleaseStatusAndBuild: true) == rhs.toString(outputFormat: Constants.OutputFormat.full, javaFormat: true, includeReleaseStatusAndBuild: true)
    }
    */
}
