//
//  Storage.swift
//  GlucoTracker
//
//  Created by Gerrit Grunwald on 01.08.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import SwiftUI
import os.log


extension Key {
    static let showOnboardingView : Key = "showOnboardingView"
    static let duration           : Key = "duration"
}



// Define storage
public struct Properties {
    
    static var instance = Properties()
    
    @UserDefault(key: .showOnboardingView, defaultValue: true)
    var showOnboardingView: Bool?
    
    @UserDefault(key: .duration, defaultValue: Constants.Duration.MIN_1.seconds)
    var duration: TimeInterval?
    
    
    private init() {}
}
