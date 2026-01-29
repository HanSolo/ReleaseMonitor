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
            Tab {
                JDKView()
            }
            
            if self.model.networkMonitor.isOnline {
                Tab {
                    DiscoView()
                }
                .disabled(!self.model.discoApiAvailable)
                 
                Tab {
                    MarketPlaceView()
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Constants.AZUL_BLUE)
        .task {            
            /*
            self.model.ltsReleases.forEach { key, value in
                debugPrint(key.uiString)
                for version in value {
                    debugPrint(version.toString(outputFormat: .reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                }
            }
            */
        }
    }
}

