//
//  MarketPlaceView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 23.12.25.
//

import SwiftUI

struct MarketPlaceView: View {
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
                    Image("marketplace").resizable().frame(width: 50, height: 50)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.08 * context.height
                        }
                    Text("Marketplace")
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
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            
                ForEach(Constants.VENDOR_NAMES, id: \.self) { vendor in
                    HStack {
                        Text(vendor)
                            .font(distroFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(self.model.latestOnMarketPlace[vendor]!.toString(outputFormat: Constants.OutputFormat.reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))
                            .font(versionFont)
                            .foregroundStyle(Constants.AZUL_LIGHT_BLUE)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MarketPlaceView()
}
