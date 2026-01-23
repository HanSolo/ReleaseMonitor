//
//  ContentView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import SwiftUI

struct ContentView: View {
    @Environment(ReleaseModel.self) private var model : ReleaseModel
    
    
    var body: some View {        
        TabView {
            //Tab("JDK", image: "jdk") {
            Tab {
                JDKView()
            }
            
            //Tab("Disco API", image: "disco") {
            Tab {
                DiscoView()
            }
            .disabled(!self.model.networkMonitor.isOnline || !self.model.discoApiAvailable)
            
            //Tab("MarketPlace", image: "marketplace") {
            Tab {
                MarketPlaceView()
            }
            .disabled(!self.model.networkMonitor.isOnline)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Constants.AZUL_BLUE)
        .task {
            let lastUpdate  : JDKUpdate = Helper.getLastUpdate()
            let lastRelease : JDKUpdate = Helper.getLastRelease()
            let nextUpdate  : JDKUpdate = Helper.getNextUpdate()
            let nextRelease : JDKUpdate = Helper.getNextRelease()
        
            debugPrint("Last Update : \(lastUpdate.remainingDays) days ago on \(Constants.DF_ISO.string(from: lastUpdate.date))")
            debugPrint("Last Release: \(lastRelease.remainingDays) days ago aon \(Constants.DF_ISO.string(from: lastRelease.date))")
            debugPrint("Next Update : in \(nextUpdate.remainingDays) days on \(Constants.DF_ISO.string(from: nextUpdate.date))")
            debugPrint("Next Release: in \(nextRelease.remainingDays) days aon \(Constants.DF_ISO.string(from: nextRelease.date))")
            
            self.model.update()
        }
    }
}

