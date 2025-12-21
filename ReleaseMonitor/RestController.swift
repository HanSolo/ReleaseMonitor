//
//  RestController.swift
//  JDKMonitor
//
//  Created by Gerrit Grunwald on 07.10.23.
//

import Foundation
import Network
import SwiftUI
import os.log


class RestController {
    private static let LOG = OSLog.init(subsystem: "RestController", category: "JDKUpdater")
    
    public static func isConnected() async -> Bool {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        
        let urlString : String      = "https://www.google.com"//"http://neverssl.com/"
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "HEAD"
        do {
            let resp : (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                //debugPrint("StatusCode: \(httpResponse.statusCode)")
                return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            } else {
                debugPrint("No http response")
                return false
            }
        } catch {
            debugPrint("Error: \(error)")
            return false
        }
    }
    
    public static func checkApiAvailability() async -> Bool {
        if NetworkMonitor.shared.isConnected {            
            let urlString     : String         = Constants.DISCO_API_STATE_URL
            let finalUrl      : URL            = URL(string: urlString)!
            var request       : URLRequest     = URLRequest(url: finalUrl)
            request.httpMethod = "GET"
            do {
                let (_, response) = try await URLSession.shared.data(from: finalUrl)
                if let httpResponse = response as? HTTPURLResponse {
                    return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                } else {
                    return false
                }
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    public static func fetchMajorVersions() async -> [MajorVersion] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString     : String         = Constants.MAJOR_VERSIONS_URL
        let session       : URLSession     = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl      : URL            = URL(string: urlString)!
        var request       : URLRequest     = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var majorVersions : [MajorVersion] = []
        do {
            let data = try await session.data(with: request)
            let majorVersionsFromDisco = Helper.parseMajorVersionJSONEntries(data: data)
            if nil == majorVersionsFromDisco {
                os_log("getMajorVersions -> majorVersionsFromDisco == nil", log: LOG, type: .error)
            } else if majorVersionsFromDisco?.isEmpty ?? true {
                os_log("getMajorVersions -> majorVersionsFromDisco == empty", log: LOG, type: .error)
            } else {
                majorVersions = majorVersionsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }
            }
            
        } catch {
            os_log("Error fetching MajorVersions", log: LOG, type: .error)
        }
        return majorVersions
    }
    
    public static func fetchMajorVersionsSelection() async -> [MajorVersion] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString     : String         = Constants.MAJOR_VERSIONS_SELECTION_URL
        let session       : URLSession     = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl      : URL            = URL(string: urlString)!
        var request       : URLRequest     = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var majorVersions : [MajorVersion] = []
        do {
            let data = try await session.data(with: request)
            let majorVersionsFromDisco = Helper.parseMajorVersionJSONEntries(data: data)
            if nil == majorVersionsFromDisco {
                os_log("getMajorVersions -> majorVersionsFromDisco == nil", log: LOG, type: .error)
            } else if majorVersionsFromDisco?.isEmpty ?? true {
                os_log("getMajorVersions -> majorVersionsFromDisco == empty", log: LOG, type: .error)
            } else {
                majorVersions = majorVersionsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }
            }
            
        } catch {
            os_log("Error fetching MajorVersions", log: LOG, type: .error)
        }
        return majorVersions
    }
    
    public static func fetchLatestBuildAvailableForMajorVersion(majorVersion: Int, packageType: Constants.PackageType, releaseStatus: Constants.ReleaseStatus, archiveType: Constants.ArchiveType) async -> [Pkg] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String = "\(Constants.PKG_URL)\(majorVersion)&distribution=zulu&operating_system=macos&archive_type=\(archiveType.apiString)&release_status=\(releaseStatus.apiString)&latest=available&package_type=\(packageType.apiString)&architecture=\(Helper.getArchitecture().apiString)"
        let session   : URLSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL        = URL(string: urlString)!
        var request   : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var pkgs      : [Pkg]      = []
        do {
            let data = try await session.data(with: request)
            let pkgsFromDisco = Helper.parsePkgsJSONEntries(data: data)
            if nil == pkgsFromDisco {
                os_log("getPkgs -> pkgsFromDisco == nil", log: LOG, type: .error)
            } else if pkgsFromDisco?.isEmpty ?? true {
                os_log("getPkgs -> pkgsFromDisco == empty", log: LOG, type: .error)
            } else {
                pkgs = pkgsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }
            }
            
        } catch {
            os_log("Error fetching Pkgs", log: LOG, type: .error)
        }
        return pkgs
    }
        
    public static func fetchLatestBuildAvailableFor(jvm: JVM) async -> [Pkg] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String = "\(Constants.DISCO_API_BASE_URL)packages?version=\(jvm.versionNumber.feature!)&distribution=\(jvm.distro.apiString)&architecture=\(Helper.getArchitecture().apiString)&package_type=\(jvm.packageType.apiString)&operating_system=macos&javafx_bundled=\(jvm.fx ? "true" : "false")&release_status=ea&release_status=ga\(jvm.crac ? "&feature=crac" : "")&latest=available"
        let session   : URLSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL        = URL(string: urlString)!
        var request   : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var pkgs      : [Pkg]      = []
        do {
            let data = try await session.data(with: request)
            let pkgsFromDisco = Helper.parsePkgsJSONEntries(data: data)
            if nil == pkgsFromDisco {
                os_log("getPkgs -> pkgsFromDisco == nil", log: LOG, type: .error)
            } else if pkgsFromDisco?.isEmpty ?? true {
                os_log("getPkgs -> pkgsFromDisco == empty", log: LOG, type: .error)
            } else {
                pkgs = pkgsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }
            }
            
        } catch {
            os_log("Error fetching Pkgs", log: LOG, type: .error)
        }
        return pkgs
    }
    
    public static func fetchAvailablePkgs(url: String) async -> [Pkg] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String = url
        let session   : URLSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL        = URL(string: urlString)!
        var request   : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var pkgs      : [Pkg]      = []
        do {
            let data = try await session.data(with: request)
            let pkgsFromDisco = Helper.parsePkgsJSONEntries(data: data)
            if nil == pkgsFromDisco {
                os_log("getPkgs -> pkgsFromDisco == nil", log: LOG, type: .error)
            } else if pkgsFromDisco?.isEmpty ?? true {
                os_log("getPkgs -> pkgsFromDisco == empty", log: LOG, type: .error)
            } else {
                pkgs = pkgsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }
            }
            
        } catch {
            os_log("Error fetching Pkgs", log: LOG, type: .error)
        }
        return pkgs
    }
    
    public static func fetchLatestEaVersion() async throws -> MajorVersion? {
        let urlString = Constants.LATEST_EA_VERSION_URL
        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
                
        var request        = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
    
        let majorVersionsFromDisco = Helper.parseMajorVersionJSONEntries(data: data)
        if nil == majorVersionsFromDisco {
            return nil
        } else if majorVersionsFromDisco?.isEmpty ?? true {
            return nil
        } else {
            let majorVersion : MajorVersion = majorVersionsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }.first!
            return majorVersion
        }
    }
    
    public static func fetchLatestMajorVersions(releaseStatus: Constants.ReleaseStatus) async -> [MajorVersion] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString     : String      = releaseStatus == .ea ? Constants.LATEST_EA_VERSION_URL : Constants.LATEST_GA_VERSION_URL
        let session       : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl      : URL         = URL(string: urlString)!
        var request       : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var majorVersions : [MajorVersion] = []
        do {
            let data = try await session.data(with: request)
            let majorVersionsFromDisco = Helper.parseMajorVersionJSONEntries(data: data)
            if nil == majorVersionsFromDisco {
                os_log("getMajorVersions -> majorVersionsFromDisco == nil", log: LOG, type: .error)
            } else if majorVersionsFromDisco?.isEmpty ?? true {
                os_log("getMajorVersions -> majorVersionsFromDisco == empty", log: LOG, type: .error)
            } else {
                majorVersions = majorVersionsFromDisco!.sorted() { $0.majorVersion < $1.majorVersion }
            }
            
        } catch {
            os_log("Error fetching MajorVersions", log: LOG, type: .error)
        }
        return majorVersions
    }

    public static func fetchVersionsForDistro(for distribution: Distro) async -> [VersionNumber] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String      = "\(Constants.VERSIONS_PER_DISTRO_URL)\(distribution.apiString)?include_ea=false"
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var versions : [VersionNumber] = []
        do {
            let data = try await session.data(with: request)
            let versionsFromDisco = Helper.parseDistributionJSONEntries(data: data)
            if nil == versionsFromDisco {
                os_log("fetchVersionsForDistro -> versionsFromDisco == nil", log: LOG, type: .error)
            } else if versionsFromDisco?.isEmpty ?? true {
                os_log("fetchVersionsForDistro -> versionsFromDisco == empty", log: LOG, type: .error)
            } else {
                versions = versionsFromDisco!.sorted() { $0 < $1 }
            }
        } catch {
            os_log("Error fetching versions for distribution", log: LOG, type: .error)
        }
        return versions
    }
    
    public static func fetchUpcomingReleases() async -> [UpcomingReleases] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String      = Constants.DISCO_UPCOMING_RELEASES_URL
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var upcomingReleases : [UpcomingReleases] = []
        do {
            let data = try await session.data(with: request)
            let upcomingReleasesFromDisco = Helper.parseUpcomingReleasesJSONEntries(data: data)
            if nil == upcomingReleasesFromDisco {
                os_log("fetchUpcomingReleases -> upcomingReleasesFromDisco == nil", log: LOG, type: .error)
            } else if upcomingReleasesFromDisco?.isEmpty ?? true {
                os_log("fetchUpcomingReleases -> upcomingReleasesFromDisco == empty", log: LOG, type: .error)
            } else {
                upcomingReleases = upcomingReleasesFromDisco!
            }
        } catch {
            os_log("Error fetching upcomingReleases", log: LOG, type: .error)
        }
        return upcomingReleases
    }
    
    public static func fetchLatestVersions() async -> [DistributionVersions] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String      = Constants.DISCO_LATEST_VERSIONS_URL
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var distributionVersions : [DistributionVersions] = []
        do {
            let data = try await session.data(with: request)
            let distributionVersionsFromDisco = Helper.parseDistributionVersionsJSONEntries(data: data)
            if nil == distributionVersionsFromDisco {
                os_log("fetchLatestVersions -> distributionVersionsFromDisco == nil", log: LOG, type: .error)
            } else if distributionVersionsFromDisco?.isEmpty ?? true {
                os_log("fetchLatestVersions -> distributionVersionsFromDisco == empty", log: LOG, type: .error)
            } else {
                distributionVersions = distributionVersionsFromDisco!
            }
        } catch {
            os_log("Error fetching latest versions", log: LOG, type: .error)
        }
        return distributionVersions
    }
    
    public static func fetchTextFromUrl(url: String, encoding: String.Encoding) async -> String {
        let url  = URL(string: url)!
        let urlRequest = URLRequest(url: url)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching text from url \(url)") }
            let text : String = String(data: data, encoding: encoding) ?? ""
            return text
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
    
    public static func fetchSourceFromUrl(url: String, encoding: String.Encoding) async -> String {
        guard let url = URL(string: url) else {
            print("Error: \(url) doesn't seem to be a valid URL")
            return ""
        }

        do {
            let text : String = try String(contentsOf: url, encoding: encoding)
            return text
        } catch let error {
            print("Error: \(error)")
            return ""
        }

    }
    
    public static func fetchCVEs(url: String, jdkType: Constants.JDKType) async -> [CVE] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let session       : URLSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl      : URL        = URL(string: url)!
        var request       : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.addValue(Constants.NVD_API_KEY, forHTTPHeaderField: "apiKey")        
        
        var cvesFound : [CVE] = []
        do {
            let data            = try await session.data(with: request)
            let json            = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            let vulnerabilities = json["vulnerabilities"] as! [[String:Any]]
            vulnerabilities.forEach {
                let cve = $0["cve"] as! [String:Any]
                let id    : String           = cve["id"] as! String
                var vmType: Constants.VMType = Constants.VMType.none
                
                let configurations = cve["configurations"] as! [[String:Any]]
                configurations.forEach {
                    var cpesFound : [String:[String]] = [:]
                    let nodes = $0["nodes"] as! [[String:Any]]
                    nodes.forEach {
                        let cpeMatch = $0["cpeMatch"] as! [[String:Any]]
                        cpeMatch.forEach {
                            let vulnerable = $0["vulnerable"] as! Bool
                            let criteria   = $0["criteria"]   as! String
                            if vulnerable {
                                var parts : [String]         = []
                                switch jdkType {
                                    case .graalvm:
                                        if criteria.starts(with: "cpe:2.3:a:oracle:") {
                                            if criteria.starts(with: "cpe:2.3:a:oracle:graalvm:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:graalvm:", with: "").components(separatedBy: ":")
                                                if criteria.contains("enterprise") {
                                                    if vmType == .community || vmType == .both {
                                                        vmType = .both
                                                    } else {
                                                        vmType = .enterprise
                                                    }
                                                } else if criteria.contains("community") {
                                                    if vmType == .enterprise || vmType == .both {
                                                        vmType = .both
                                                    } else {
                                                        vmType = .community
                                                    }
                                                } else {
                                                    vmType = .none
                                                }
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:graalvm_for_jdk:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:graalvm_for_jdk:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:openjdk:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:openjdk:", with: "").components(separatedBy: ":")
                                            } else {
                                                parts = []
                                            }
                                        }
                                    case .openjdk:
                                        if criteria.starts(with: "cpe:2.3:a:oracle:") {
                                            if criteria.starts(with: "cpe:2.3:a:oracle:openjdk:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:openjdk:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:jdk:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:jdk:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:jre:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:jre:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:java_se:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:java_se:", with: "").components(separatedBy: ":")
                                            } else {
                                                parts = []
                                            }
                                        }
                                    case .zulu:
                                        if vulnerable && criteria.starts(with: "cpe:2.3:a:azul:") {
                                            if criteria.starts(with: "cpe:2.3:a:azul:zulu:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:azul:zulu:", with: "").components(separatedBy: ":")
                                            } else {
                                                parts = []
                                            }
                                        }
                                    case .openj9:
                                        if vulnerable && criteria.starts(with: "cpe:2.3:a:ibm:") {
                                            if criteria.starts(with: "cpe:2.3:a:ibm:semeru_runtime:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:ibm:semeru_runtime:", with: "").components(separatedBy: ":")
                                            } else {
                                                parts = []
                                            }
                                        }
                                    default:
                                        if vulnerable && criteria.starts(with: "cpe:2.3:a:oracle:") {
                                            if criteria.starts(with: "cpe:2.3:a:oracle:openjdk:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:openjdk:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:jdk:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:jdk:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:jre:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:jre:", with: "").components(separatedBy: ":")
                                            } else if criteria.starts(with: "cpe:2.3:a:oracle:java_se:") {
                                                parts = criteria.replaceAll(of: "cpe:2.3:a:oracle:java_se:", with: "").components(separatedBy: ":")
                                            } else {
                                                parts = []
                                            }
                                        }
                                }
                                
                                if parts.count != 0 {
                                    var version = parts[0]
                                    if version != "*" {
                                        if parts[1].starts(with: "update") {
                                            if parts[1].starts(with: "update_0") {
                                                version += parts[1].replaceAll(of: "update_0", with: ".0.")
                                            } else if parts[1].starts(with: "update_") {
                                                version += parts[1].replaceAll(of: "update_", with: ".0.")
                                            } else {
                                                version += parts[1].replaceAll(of: "update", with: ".0.")
                                            }
                                            if !cpesFound.keys.contains(id) { cpesFound[id] = [] }
                                            version = version.replaceAll(of: "1.2", with: "2")
                                            version = version.replaceAll(of: "1.3", with: "3")
                                            version = version.replaceAll(of: "1.4", with: "4")
                                            version = version.replaceAll(of: "1.5", with: "5")
                                            version = version.replaceAll(of: "1.6", with: "6")
                                            version = version.replaceAll(of: "1.7", with: "7")
                                            version = version.replaceAll(of: "1.8", with: "8")
                                            version = version.replaceAll(of: "1.9", with: "9")
                                            version = version.replaceAll(of: ".0.0.", with: ".0.")
                                            version = version.replaceAll(of: "_b", with: "+")
                                            
                                            if !cpesFound[id]!.contains(version) && version != "-" {
                                                cpesFound[id]!.append(version)
                                            }
                                        } else {
                                            if !cpesFound.keys.contains(id) { cpesFound[id] = [] }
                                            version = version.replaceAll(of: "1.2", with: "2")
                                            version = version.replaceAll(of: "1.3", with: "3")
                                            version = version.replaceAll(of: "1.4", with: "4")
                                            version = version.replaceAll(of: "1.5", with: "5")
                                            version = version.replaceAll(of: "1.6", with: "6")
                                            version = version.replaceAll(of: "1.7", with: "7")
                                            version = version.replaceAll(of: "1.8", with: "8")
                                            version = version.replaceAll(of: "1.9", with: "9")
                                            version = version.replaceAll(of: ".0.0", with: "")
                                            version = version.replaceAll(of: "_b", with: "+")
                                            
                                            if !cpesFound[id]!.contains(version) && version != "-" {
                                                cpesFound[id]!.append(version)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    let metrics       : [String:Any]       = cve["metrics"] as! [String:Any]
                    var scoreFound    : Double             = -1
                    var severityFound : Constants.Severity = Constants.Severity.none
                    var cvssFound     : Constants.CVSS     = Constants.CVSS.not_found
                    if metrics.keys.contains(Constants.CVSS.cvssv40.metricString) {
                        cvssFound = Constants.CVSS.cvssv40
                        let cvssMetricsV40 = metrics[Constants.CVSS.cvssv40.metricString] as! [[String:Any]]
                        if cvssMetricsV40.count > 0 {
                            let metrics   = cvssMetricsV40[0]
                            let cvssData  = metrics["cvssData"] as! [String:Any]
                            scoreFound    = cvssData["baseScore"] as! Double
                            severityFound = Constants.Severity.fromText(text: cvssData["baseSeverity"] as! String)
                        }
                    } else if metrics.keys.contains(Constants.CVSS.cvssv31.metricString) {
                        cvssFound = Constants.CVSS.cvssv30
                        let cvssMetricsV31 = metrics[Constants.CVSS.cvssv31.metricString] as! [[String:Any]]
                        if cvssMetricsV31.count > 0 {
                            let metrics   = cvssMetricsV31[0]
                            let cvssData  = metrics["cvssData"] as! [String:Any]
                            scoreFound    = cvssData["baseScore"] as! Double
                            severityFound = Constants.Severity.fromText(text: cvssData["baseSeverity"] as! String)
                        }
                    } else if metrics.keys.contains(Constants.CVSS.cvssv30.metricString) {
                        cvssFound = Constants.CVSS.cvssv30
                        let cvssMetricsV30 = metrics[Constants.CVSS.cvssv30.metricString] as! [[String:Any]]
                        if cvssMetricsV30.count > 0 {
                            let metrics   = cvssMetricsV30[0]
                            let cvssData  = metrics["cvssData"] as! [String:Any]
                            scoreFound    = cvssData["baseScore"] as! Double
                            severityFound = Constants.Severity.fromText(text: cvssData["baseSeverity"] as! String)
                        }
                    } else if metrics.keys.contains(Constants.CVSS.cvssv2.metricString) {
                        cvssFound = Constants.CVSS.cvssv2
                        let cvssMetricsV2 = metrics[Constants.CVSS.cvssv2.metricString] as! [[String:Any]]
                        if cvssMetricsV2.count > 0 {
                            let metrics   = cvssMetricsV2[0]
                            let cvssData  = metrics["cvssData"] as! [String:Any]
                            scoreFound    = cvssData["baseScore"] as! Double
                            severityFound = Constants.Severity.fromText(text: metrics["baseSeverity"] as! String)
                        }
                    }
                    if !cpesFound.isEmpty && scoreFound > 0 && severityFound != Constants.Severity.none {
                        var versionsFound : [VersionNumber] = []
                        cpesFound.values.forEach { versions in
                            versions.forEach { version in
                                let versionNumber : VersionNumber = VersionNumber.fromText(text: version)
                                if versionNumber.feature! > 1 { versionsFound.append(versionNumber) }
                                //versionsFound.append(VersionNumber.fromText(text: version))
                            }
                        }
                        let sortedVersions : [VersionNumber] = versionsFound.sorted(by: { $0 < $1 })
                        cvesFound.append(CVE(id: id, score: scoreFound, cvss: cvssFound, severity: severityFound, vmType: vmType, affectedVersions: sortedVersions))
                    }
                }
            }
            os_log("CVEs fetched successfully", log: LOG, type: .debug)
        } catch {
            os_log("Error fetching CVEs", log: LOG, type: .error)
        }
        return cvesFound
    }
    
    public static func fetchLatestJDKUpdaterVersion() async -> (VersionNumber?,String?) {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let session  : URLSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl : URL        = URL(string: Constants.GITHUB_RELEASES_URL)!
        
        var request  : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        
        return await withCheckedContinuation { continuation in
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print("Error fetching CVEs: \(error.debugDescription)")
                    return
                }
                
                guard response != nil else { return }
                guard let data1 = data else { return }
                var versionNumber: VersionNumber?
                var pkgUrl       : String?
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data1, options: []) as! [String:Any]
                    
                    let tagName = json["tag_name"] as! String
                    versionNumber = VersionNumber.fromText(text: tagName)
                    let assets = json["assets"] as! [[String:Any]]
                    assets.forEach {
                        let name               = $0["name"] as! String
                        let browserDownloadUrl = $0["browser_download_url"]  as! String
                        if name.hasSuffix("pkg") {
                            if !browserDownloadUrl.isEmpty {                            
                                pkgUrl = browserDownloadUrl
                            }
                        }
                    }
                } catch {
                    print("Error fetching latest version of JDK-Updater")
                }
                os_log("Successfully fetched latest JDK Updater version", log: LOG, type: .debug)
                continuation.resume(returning: (versionNumber, pkgUrl))
            })
            task.resume()
        }
    }
    
    public static func fetchJavaReleaseInfo(version: String) async throws(NetworkingError) -> JavaRelease {       
        do {
            let url     : URL        = URL(string: "\(Constants.JAVA_RELEASES_URL)\(version)")!
            var request : URLRequest = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
            /// Use URLSession to fetch the data asynchronously.
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkingError.invalidStatusCode(statusCode: -1)
            }
            
            guard (200...299).contains(statusCode) else {
                throw NetworkingError.invalidStatusCode(statusCode: statusCode)
            }
            
            let javaRelease = try JSONDecoder().decode(JavaRelease.self, from: data)
            return javaRelease
        } catch let error as DecodingError {
            throw .decodingFailed(innerError: error)
        } catch let error as EncodingError {
            throw .encodingFailed(innerError: error)
        } catch let error as URLError {
            throw .requestFailed(innerError: error)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw .otherError(innerError: error)
        }
    }
    
    public static func fetchAdvisories() async -> [Advisory] {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
        
        let urlString : String      = "\(Constants.FOOJAY_ADVISORIES_URL)"
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var advisories : [Advisory] = []
        do {
            let data                = try await session.data(with: request)
            let advisoriesFromDisco = Helper.parseAdvisoriesJSONEntries(data: data)
            if nil == advisoriesFromDisco {
                os_log("fetchAdvisories -> advisoriesFromDisco == nil", log: LOG, type: .error)
            } else if advisoriesFromDisco?.isEmpty ?? true {
                os_log("fetchVersionsAdvisories -> advisoriesFromDisco == empty", log: LOG, type: .error)
            } else {
                advisories = advisoriesFromDisco!
            }
        } catch {
            os_log("Error fetching versions for advisories", log: LOG, type: .error)
        }
        return advisories
    }
    
    public static func fetchCVEInfo(cveId: String) async -> CVEInfo? {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = Constants.REQUEST_TIMEOUT
        sessionConfig.timeoutIntervalForResource = Constants.RESOURCE_TIMEOUT
                
        let urlString : String      = "\(Constants.CVEDB_API_URL)\(cveId)"
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        var cveInfo : CVEInfo?
        do {
            let data = try await session.data(with: request)
            cveInfo = try! JSONDecoder().decode(CVEInfo.self, from: data)
            if nil == cveInfo {
                os_log("fetchCVEInfo -> cveInfo == nil", log: LOG, type: .error)
            }
        } catch {
            os_log("Error fetching CVEInfo", log: LOG, type: .error)
        }
        return cveInfo
    }
    
    public static func fetchOpenJDKSecurityAdvisories() async -> [SecurityAdvisory] {
        let htmlSource : String   = await fetchSourceFromUrl(url: Constants.JDK_SEC_ADVISORIES_URL, encoding: .utf8)
        var advisories : [SecurityAdvisory] = []
        for result in htmlSource.matches(of: Constants.JDK_ADVISORY_PATTERN) {
            let dateString  : String = String(result.1).htmlDecoded
            let url         : String = "\(Constants.JDK_SEC_ADVISORIES_URL)\(dateString)"
            let latest      : Bool   = result.3 != nil
            advisories.append(SecurityAdvisory(dateString: dateString, latest: latest, url: url))
        }
        return advisories.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
    }
}
