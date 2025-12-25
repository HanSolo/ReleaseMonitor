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
            .disabled(!self.model.networkMonitor.isOnline)
            
            //Tab("MarketPlace", image: "marketplace") {
            Tab {
                MarketPlaceView()
            }
            .disabled(!self.model.networkMonitor.isOnline)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Constants.AZUL_BLUE)
        .task {
            self.model.update()
        }
    }
}

