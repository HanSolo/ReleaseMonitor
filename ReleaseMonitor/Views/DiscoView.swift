//
//  DiscoView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 23.12.25.
//

import SwiftUI

struct DiscoView: View {
    @Environment(ReleaseModel.self) var model : ReleaseModel
    
    
    var body: some View {
        ZStack {
            let titleFont   : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 62)
            let subtitleFont: Font = Font.custom("MetaHeadlineWebW04-Light", size: 20)
            let distroFont  : Font = Font.custom("MetaHeadlineWebW04-Light", size: 24)
            let versionFont : Font = Font.custom("MetaHeadlineWebW04-Light", size: 24)
            Constants.AZUL_BLUE
                .ignoresSafeArea()
            VStack(spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 15) {
                    Image("disco").resizable().frame(width: 55, height: 55, alignment: .bottom)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.08 * context.height
                        }
                    Text("Disco API")
                        .font(titleFont)
                        .foregroundStyle(.white)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                
                HStack {
                    Text("DISTRIBUTION")
                        .font(subtitleFont)
                        .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                    Spacer()
                    Text("GA RELEASE")
                        .font(subtitleFont)
                        .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                        .frame(minWidth: 120, alignment: .trailing)
                    Text("EA RELEASE")
                        .font(subtitleFont)
                        .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                        .frame(minWidth: 120, alignment: .trailing)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                ForEach(self.model.distributions.sorted(by: { $0.uiString < $1.uiString }), id: \.self) { distro in
                    HStack {
                        Text(distro.uiString)
                            .font(distroFont)
                            .foregroundStyle(.white)
                        Spacer()
                        HStack(spacing: 20) {
                            Text(distro.latestGA!.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                                .frame(minWidth: 120, alignment: .trailing)
                                .font(versionFont)
                                .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                            if distro.latestEA != nil && distro.latestEA!.feature != 1 {
                                Text(distro.latestEA!.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: true))
                                    .frame(minWidth: 120, alignment: .trailing)
                                    .font(versionFont)
                                    .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                            } else {
                                Spacer()
                                    .frame(maxWidth: 120)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}
