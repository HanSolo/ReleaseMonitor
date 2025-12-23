//
//  ReleaseMonitorApp.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import SwiftUI

@main
struct ReleaseMonitorApp: App {
    
    @State var model : ReleaseModel = ReleaseModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(self.model)
        }
    }
}
