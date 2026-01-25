//
//  JDKView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 23.12.25.
//

import SwiftUI

struct JDKView: View {
    @Environment(ReleaseModel.self) var model : ReleaseModel
    
    
    var body: some View {
        ZStack {
            let releaseFontBig        : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 96)
            let releaseFont           : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 32)
            let releaseFontLight      : Font = Font.custom("MetaHeadlineWebW04-Light", size: 28)
            let releaseFontLightSmall : Font = Font.custom("MetaHeadlineWebW04-Light", size: 24)
            let updateFontBig         : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 66)
            let updateFont            : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 32)
            let updateFontLighter     : Font = Font.custom("MetaHeadlineWebW04-Light", size: 24)
            let updateFontLight       : Font = Font.custom("MetaHeadlineWebW04-Light", size: 28)
            let updateFontLightSmall  : Font = Font.custom("MetaHeadlineWebW04-Light", size: 24)
            
            Constants.AZUL_BLUE
                .ignoresSafeArea()
            VStack(spacing: 3) {
                // Next Release
                let nextRelease             : JDKUpdate = Helper.getNextRelease()
                let daysUntilNextRelease    : Int       = nextRelease.remainingDays
                let jdkText                 : Text      = Text("JDK").foregroundStyle(.white)
                let jdkVersion              : Text      = Text(" \(self.model.nextRelease) ").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                let daysUntilReleaseVisible : Bool      = daysUntilNextRelease == 0 ? false : daysUntilNextRelease == 1 ? false : true
                let releaseDaysTxt          : Text      = Text(daysUntilNextRelease == 0 ? "comes today" : daysUntilNextRelease == 1 ? "comes tomorrow" : "comes in").foregroundStyle(.white)
                let daysNumberText          : Text      = Text(daysUntilReleaseVisible ? " \(daysUntilNextRelease) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                let daysText                : Text      = Text(daysUntilReleaseVisible ? "days" : "").foregroundStyle(.white)
                
                Text("\(jdkText)\(jdkVersion)")
                    .font(releaseFontBig)
                
                Text("\(releaseDaysTxt)\(daysNumberText)\(daysText)")
                    .font(releaseFont)
                Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: nextRelease.date)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                    .font(releaseFontLight)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                // Last Release
                let lastRelease                  : JDKUpdate = Helper.getLastRelease()
                let daysSinceLastRelease         : Int       = lastRelease.remainingDays
                let daysSinceLastReleaseVisible  : Bool      = daysSinceLastRelease == 1 ? false : true
                let lastReleaseDaysTxt           : Text      = Text(daysSinceLastRelease == 1 ? "JDK \(self.model.lastRelease) came yesterday" : "JDK \(self.model.lastRelease) came").foregroundStyle(.white)
                let lastRelaseDaysNumberText     : Text      = Text(daysSinceLastReleaseVisible ? " \(daysSinceLastRelease) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                let lastReleaseDaysText          : Text      = Text(daysSinceLastReleaseVisible ? "days ago" : "").foregroundStyle(.white)
                
                Text("\(lastReleaseDaysTxt)\(lastRelaseDaysNumberText)\(lastReleaseDaysText)")
                    .font(releaseFontLightSmall)
                    .opacity(0.6)
                Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: lastRelease.date)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                    .font(releaseFontLightSmall)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
                    .opacity(0.6)
                
                // Next Update
                let nextUpdate             : JDKUpdate = Helper.getNextUpdate()
                let daysUntilNextUpdate    : Int       = nextUpdate.remainingDays
                let updatesText            : Text      = Text(daysUntilNextUpdate == 0 ? "coming today" : daysUntilNextUpdate == 1 ? "coming tomorrow" : "coming in").foregroundStyle(.white)
                let daysUntilUpdateVisible : Bool      = daysUntilNextUpdate == 0 ? false : daysUntilNextUpdate == 1 ? false : true
                let updateInDaysText       : Text      = Text(daysUntilUpdateVisible ? " \(daysUntilNextUpdate) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                let updateDaysText         : Text      = Text(daysUntilUpdateVisible ? "days" : "").foregroundStyle(.white)
                
                Text("Updates")
                    .font(updateFontBig)
                    .foregroundStyle(.white)
                
                Text("\(updatesText)\(updateInDaysText)\(updateDaysText)")
                    .font(updateFont)
                
                Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: nextUpdate.date)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                    .font(updateFontLight)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                // Last Updates
                let lastUpdate                   : JDKUpdate = Helper.getLastUpdate()
                let daysSinceLastUpdate          : Int       = lastUpdate.remainingDays
                let daysSinceLastUpdateVisible   : Bool      = daysSinceLastUpdate == 1 ? false : true
                let lastUpdateDaysTxt            : Text      = Text("last updates came\(daysSinceLastUpdate == 1 ? " yesterday" : "")").foregroundStyle(.white)
                let lastUpdateDaysNumberText     : Text      = Text(daysSinceLastUpdateVisible ? " \(daysSinceLastUpdate) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                let lastUpdateDaysText           : Text      = Text(daysSinceLastUpdateVisible ? "days ago" : "").foregroundStyle(.white)
                
                Text("\(lastUpdateDaysTxt)\(lastUpdateDaysNumberText)\(lastUpdateDaysText)")
                    .font(updateFontLightSmall)
                    .opacity(0.6)
                Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: lastUpdate.date)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                    .font(updateFontLightSmall)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                    .opacity(0.6)
                
                
                // Upcoming updates
                if let upcomingRelease = self.model.upcomingReleases.first {
                    HStack(spacing: 10) {
                        ForEach(upcomingRelease.getVersionsOfNextUpdates().sorted(by: { $0.feature! > $1.feature! }), id: \.self) { version in
                            Text(version.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                                .font(updateFontLighter)
                                .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                        }
                    }
                }
                      
                Spacer()
                
                HStack {
                    Text("OFFLINE")
                        .font(.system(size: 9))
                        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                        .foregroundStyle(.white)
                        .background(
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 9,
                                    style       : .continuous
                                )
                                .fill(.red)
                                RoundedRectangle(
                                    cornerRadius: 9,
                                    style       : .continuous
                                )
                                .stroke(.red, lineWidth: 1)
                            }
                        )
                        .opacity(self.model.networkMonitor.isOnline ? 0.0 : 1.0)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await self.model.update()
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            Text("Update")
                        }
                    })
                    .buttonStyle(.bordered)
                    .disabled(!self.model.networkMonitor.isOnline)
                    
                    Spacer()
                    
                    Text("API OFFLINE")
                        .font(.system(size: 9))
                        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                        .foregroundStyle(.black)
                        .background(
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 9,
                                    style       : .continuous
                                )
                                .fill(.yellow)
                                RoundedRectangle(
                                    cornerRadius: 9,
                                    style       : .continuous
                                )
                                .stroke(.yellow, lineWidth: 1)
                            }
                        )
                        .opacity(self.model.discoApiAvailable ? 0.0 : 1.0)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0))
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }
        .task {
            if self.model.networkMonitor.isOnline {
                await self.model.update()
            }
        }
    }
}
