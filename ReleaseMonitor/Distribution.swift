//
//  Distribution.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import Foundation

public class Distribution {
    public let uiString  : String
    public let apiString : String
    public var latestGA  : VersionNumber?
    public var latestEA  : VersionNumber?
    
    
    public init(uiString: String, apiString: String, latestGA: VersionNumber?, latestEA: VersionNumber?) {
        switch apiString {
            case "liberica_native"  : self.uiString = "Liberica NIK"
            case "graalvm_community": self.uiString = "GraalVM CE"
            case "oracle_open_jdk"  : self.uiString = "OpenJDK"
            default                 : self.uiString = uiString
        }
        self.apiString = apiString
        self.latestGA  = latestGA
        self.latestEA  = latestEA
    }
}
