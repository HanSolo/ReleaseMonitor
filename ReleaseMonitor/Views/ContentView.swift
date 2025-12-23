//
//  ContentView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import SwiftUI

struct ContentView: View {
    @Environment(ReleaseModel.self) var model : ReleaseModel
    
    
    var body: some View {
        TabView {
            
            Tab("JDK", systemImage: "house") {
                JDKView()
            }
            Tab("Disco API", image: "disco") {
                DiscoView()
            }
            Tab("MarketPlace", image: "marketplace") {
                MarketPlaceView()
            }
        }                
        .task {
            self.model.update()
        }
    }
}

