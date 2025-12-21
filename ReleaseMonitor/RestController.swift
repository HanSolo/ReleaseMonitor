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
    private static let LOG = OSLog.init(subsystem: "RestController", category: "ReleaseMonitor")
    
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
}
