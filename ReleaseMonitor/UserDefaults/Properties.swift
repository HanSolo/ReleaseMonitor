//
//  Storage.swift
//  GlucoTracker
//
//  Created by Gerrit Grunwald on 01.08.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import SwiftUI


extension Key {
    static let lastUpdate : Key = "lastUpdate" // epoch seconds of last update
}



// Define storage
public struct Properties {
    
    static var instance = Properties()
    
    @UserDefault(key: .lastUpdate, defaultValue: Date.init().timeIntervalSince1970)
    var lastUpdate: Double?
    
    
    private init() {}
}
