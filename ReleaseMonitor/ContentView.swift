//
//  ContentView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            let upcomingReleases : [UpcomingReleases] = await RestController.fetchUpcomingReleases()
            for upcomingRelease in upcomingReleases {
                debugPrint(upcomingRelease)
            }
        }
    }
}

#Preview {
    ContentView()
}
