//
//  LtsSelectionView.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 30.01.26.
//

import SwiftUI

struct LtsSelectionView: View {
    @Environment(\.dismiss)         private var dismiss
    @Environment(ReleaseModel.self) private var model : ReleaseModel
    @State private var ltsReleases : [Int]
    @State private var selection   : Int?

    
    init(ltsReleases: [Int]? = []) {
        self.ltsReleases = ltsReleases!
    }
    
    
    var body: some View {
        ZStack {
            Constants.AZUL_BLUE
                .ignoresSafeArea()
         
            NavigationView {
                VStack {
                    List(self.ltsReleases.sorted(), id: \.self, selection: $selection) { ltsRelease in
                        Text("JDK \(ltsRelease)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .scrollContentBackground(.hidden)
                    .selectionDisabled(false)
                    .background(Constants.AZUL_BLUE)
                    .toolbarBackground(Constants.AZUL_BLUE, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    Spacer()
                }
                .navigationTitle("LTS Selection")
                .foregroundStyle(.primary)
                .background(Constants.AZUL_BLUE)
                .toolbar(content: {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Select") {
                            self.model.selectedLtsRelease = self.selection!
                            dismiss()
                        }
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.primary)
                        .disabled(self.selection == nil)
                    }
                })
            }
        }
    }
}
