//
//  LtsView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 29.01.26.
//

import SwiftUI

struct LtsView: View {
    @Environment(ReleaseModel.self) var model               : ReleaseModel
    @State                          var ltsSelectionVisible : Bool = false
    
    
    var body: some View {
        ZStack {
            let titleFont   : Font = Font.custom("MetaHeadlineWebW04-Bold", size: 60)
            let subtitleFont: Font = Font.custom("MetaHeadlineWebW04-Light", size: 20)
            let distroFont  : Font = Font.custom("MetaHeadlineWebW04-Light", size: 21)
            let versionFont : Font = Font.custom("MetaHeadlineWebW04-Light", size: 21)
            Constants.AZUL_BLUE
                .ignoresSafeArea()
                        
            VStack(spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 15) {
                    Text("LTS Releases")
                        .font(titleFont)
                        .foregroundStyle(.white)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                
                Button {
                    self.ltsSelectionVisible.toggle()
                } label: {
                    HStack {
                        Image(systemName: "filemenu.and.selection")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, weight: .light, design: .rounded))
                        Text("JDK \(self.model.selectedLtsRelease)")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, weight: .light, design: .rounded))
                    }
                }
                .buttonStyle(.glass)
                .foregroundStyle(.primary)
                .popover(isPresented: $ltsSelectionVisible) {
                    LtsSelectionView(ltsReleases : self.model.ltsReleasesAsInt)
                }
                
                HStack {
                    Text("DISTRIBUTION")
                        .font(subtitleFont)
                        .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                    Spacer()
                    Text("LTS RELEASE")
                        .font(subtitleFont)
                        .foregroundStyle(Constants.AZUL_LIGHTER_BLUE)
                        .frame(minWidth: 110, alignment: .trailing)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                ForEach(self.model.distributions.sorted(by: { $0.uiString < $1.uiString }), id: \.self) { distro in
                    HStack {
                        Text(distro.uiString)
                            .font(distroFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(Helper.getLtsForDistro(distribution: distro, ltsRelease: self.model.selectedLtsRelease, ltsReleases: self.model.ltsReleases))
                            .frame(minWidth: 110, alignment: .trailing)
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
