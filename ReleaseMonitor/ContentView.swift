//
//  ContentView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import SwiftUI

struct ContentView: View {
    @State var upcomingReleases    : [UpcomingReleases]     = []
    @State var distributions       : [Distribution]         = []
    @State var latestOnMarketPlace : [String:VersionNumber] = ["Temurin"    : VersionNumber(feature: 1),
                                                               "Dragonwell" : VersionNumber(feature: 1),
                                                               "Zulu"       : VersionNumber(feature: 1),
                                                               "Semeru"     : VersionNumber(feature: 1),
                                                               "Microsoft"  : VersionNumber(feature: 1),
                                                               "RedHat"     : VersionNumber(feature: 1)]
    
    
    var body: some View {
        ZStack {
            let nextReleaseFont      : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 24)
            let nextReleaseFontLight : Font = Font.custom("MetaHeadlineWebW04-Light", size: 20)
            let nextUpdateFont       : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 20)
            let nextUpdateFontLight  : Font = Font.custom("MetaHeadlineWebW04-Light", size: 18)
            let distroFont           : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 18)
            let versionFont          : Font = Font.custom("MetaHeadlineWebW04-Light", size: 18)
            Constants.AZUL_BLUE
                .ignoresSafeArea()
            VStack(spacing: 3) {
                if let upcomingRelease = upcomingReleases.first {
                    let daysUntilNextRelease    : Int  = upcomingRelease.daysUntilNextRelease!
                    let jdkText                 : Text = Text("JDK").foregroundStyle(.white)
                    let jdkVersion              : Text = Text(" \(upcomingRelease.getVersionOfNextRelease()!.feature!) ").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    let daysUntilReleaseVisible : Bool = daysUntilNextRelease == 0 ? false : daysUntilNextRelease == 1 ? false : true
                    let releaseDaysTxt          : Text = Text(daysUntilNextRelease == 0 ? "comes today" : daysUntilNextRelease == 1 ? "comes tomorrow" : "comes in").foregroundStyle(.white)
                    let daysNumberText          : Text = Text(daysUntilReleaseVisible ? " \(daysUntilNextRelease) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    let daysText                : Text = Text(daysUntilReleaseVisible ? "days" : "").foregroundStyle(.white)
                    
                    Text("\(jdkText)\(jdkVersion)\(releaseDaysTxt)\(daysNumberText)\(daysText)")
                        .font(nextReleaseFont)
                    Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: upcomingRelease.getDateOfNextRelease()!)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                        .font(nextReleaseFontLight)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                    
                    
                    let daysUntilNextUpdate    : Int  = upcomingRelease.daysUntilNextUpdate!
                    let updatesText            : Text = Text(daysUntilNextUpdate == 0 ? "Updates coming today" : daysUntilNextUpdate == 1 ? "Updates coming tomorrow" : "Updates coming in").foregroundStyle(.white)
                    let daysUntilUpdateVisible : Bool = daysUntilNextUpdate == 0 ? false : daysUntilNextUpdate == 1 ? false : true
                    let updateInDaysText       : Text = Text(daysUntilUpdateVisible ? " \(daysUntilNextUpdate) " : "").foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                    let updateDaysText         : Text = Text(daysUntilUpdateVisible ? "days" : "").foregroundStyle(.white)
                    
                    Text("\(updatesText)\(updateInDaysText)\(updateDaysText)")
                        .font(nextUpdateFont)
                    
                    HStack(spacing: 10) {
                        ForEach(upcomingRelease.getVersionsOfNextUpdates().sorted(by: { $0.feature! > $1.feature! }), id: \.self) { version in
                            Text(version.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                                .font(nextUpdateFontLight)
                                .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                        }
                    }
                    
                    Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: upcomingRelease.getDateOfNextUpdates()!)).foregroundStyle(Constants.AZUL_LIGHTER_BLUE))\(Text(")").foregroundStyle(.white))")
                        .font(nextUpdateFontLight)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                }
                
                
                Text("Disco API")
                    .font(distroFont)
                    .foregroundStyle(.white)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                
                ForEach(self.distributions.sorted(by: { $0.uiString < $1.uiString }), id: \.self) { distro in
                    HStack {
                        Text(distro.uiString)
                            //.font(.system(size: 18, weight: .bold, design: .rounded))
                            .font(distroFont)
                            .foregroundStyle(.white)
                        Spacer()
                        HStack(spacing: 20) {
                            Text(distro.latestGA!.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                                .frame(minWidth: 110, alignment: .trailing)
                                //.font(.system(size: 18, weight: .regular, design: .rounded))
                                .font(versionFont)
                                .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                            if distro.latestEA != nil && distro.latestEA!.feature != 1 {
                                Text(distro.latestEA!.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: true))
                                    .frame(minWidth: 110, alignment: .trailing)
                                    //.font(.system(size: 18, weight: .regular, design: .rounded))
                                    .font(versionFont)
                                    .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                            } else {
                                Spacer()
                                    .frame(maxWidth: 110)
                            }
                        }
                    }
                }
                                                
                Text("Adoptium Marketplace")
                    .font(distroFont)
                    .foregroundStyle(.white)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 5, trailing: 0))
                
                ForEach(Constants.VENDOR_NAMES, id: \.self) { vendor in
                    HStack {
                        Text(vendor)
                            .font(distroFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(self.latestOnMarketPlace[vendor]!.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                            .font(versionFont)
                            .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    }
                }
                
                Button(action: {
                    update()
                }, label: {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                        Text("Update")
                    }
                })
                .buttonStyle(.bordered)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
                Spacer()
            }
            .padding()
        }
        .task {
            update()
        }
    }
    
    private func update() -> Void {
        Task {
            self.upcomingReleases = await RestController.fetchUpcomingReleases()
            self.distributions    = await RestController.fetchDistributions()
            
            for vendor in Constants.MARKETPLACE_VENDORS.keys {
                let versionNumber: VersionNumber? = await RestController.fetchLatestReleasesFromMarketPlace(vendor: vendor)
                if nil != versionNumber {
                    let uiString : String = Constants.MARKETPLACE_VENDORS[vendor]!
                    self.latestOnMarketPlace[uiString] = versionNumber!
                }
            }
        }
    }
}

