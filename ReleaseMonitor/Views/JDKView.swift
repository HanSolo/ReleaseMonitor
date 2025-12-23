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
            let nextReleaseFontBig    : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 96)
            let nextReleaseFont       : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 32)
            let nextReleaseFontLight  : Font = Font.custom("MetaHeadlineWebW04-Light", size: 28)
            let nextUpdateFontBig     : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 66)
            let nextUpdateFont        : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 32)
            let nextUpdateFontLighter : Font = Font.custom("MetaHeadlineWebW04-Light", size: 24)
            let nextUpdateFontLight   : Font = Font.custom("MetaHeadlineWebW04-Light", size: 28)
            
            Constants.AZUL_BLUE
                .ignoresSafeArea()
            VStack(spacing: 3) {
                if let upcomingRelease = self.model.upcomingReleases.first {
                    let daysUntilNextRelease    : Int  = upcomingRelease.daysUntilNextRelease!
                    let jdkText                 : Text = Text("JDK").foregroundStyle(.white)
                    let jdkVersion              : Text = Text(" \(upcomingRelease.getVersionOfNextRelease()!.feature!) ").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    let daysUntilReleaseVisible : Bool = daysUntilNextRelease == 0 ? false : daysUntilNextRelease == 1 ? false : true
                    let releaseDaysTxt          : Text = Text(daysUntilNextRelease == 0 ? "comes today" : daysUntilNextRelease == 1 ? "comes tomorrow" : "comes in").foregroundStyle(.white)
                    let daysNumberText          : Text = Text(daysUntilReleaseVisible ? " \(daysUntilNextRelease) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    let daysText                : Text = Text(daysUntilReleaseVisible ? "days" : "").foregroundStyle(.white)
                    
                    Text("\(jdkText)\(jdkVersion)")
                        .font(nextReleaseFontBig)
                    
                    Text("\(releaseDaysTxt)\(daysNumberText)\(daysText)")
                        .font(nextReleaseFont)
                    Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: upcomingRelease.getDateOfNextRelease()!)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                        .font(nextReleaseFontLight)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
                    
                    
                    let daysUntilNextUpdate    : Int  = upcomingRelease.daysUntilNextUpdate!
                    let updatesText            : Text = Text(daysUntilNextUpdate == 0 ? "coming today" : daysUntilNextUpdate == 1 ? "coming tomorrow" : "coming in").foregroundStyle(.white)
                    let daysUntilUpdateVisible : Bool = daysUntilNextUpdate == 0 ? false : daysUntilNextUpdate == 1 ? false : true
                    let updateInDaysText       : Text = Text(daysUntilUpdateVisible ? " \(daysUntilNextUpdate) " : "").foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    let updateDaysText         : Text = Text(daysUntilUpdateVisible ? "days" : "").foregroundStyle(.white)
                    
                    Text("Updates")
                        .font(nextUpdateFontBig)
                        .foregroundStyle(.white)
                    
                    Text("\(updatesText)\(updateInDaysText)\(updateDaysText)")
                        .font(nextUpdateFont)
                    
                    Text("\(Text("(on ").foregroundStyle(.white))\(Text(Constants.DF.string(from: upcomingRelease.getDateOfNextUpdates()!)).foregroundStyle(Constants.AZUL_LIGHT_BLUE))\(Text(")").foregroundStyle(.white))")
                        .font(nextUpdateFontLight)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                    
                    HStack(spacing: 10) {
                        ForEach(upcomingRelease.getVersionsOfNextUpdates().sorted(by: { $0.feature! > $1.feature! }), id: \.self) { version in
                            Text(version.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                                .font(nextUpdateFontLighter)
                                .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                        }
                    }
                }
                                                
                Spacer()
                
                Button(action: {
                    self.model.update()
                }, label: {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                        Text("Update")
                    }
                })
                .buttonStyle(.bordered)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            }
            .padding()
        }
    }
}
