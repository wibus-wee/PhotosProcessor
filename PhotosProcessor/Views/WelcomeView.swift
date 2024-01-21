//
//  WelcomeView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import Colorful
import SwiftUI

struct WelcomeView: View {
    // let timer = Timer
    //     .publish(every: 1, on: .main, in: .common)
    //     .autoconnect()
    // @State var dotAnimation: String = ""

    var version: String {
        var ret = "Version: " +
            (Constants.appVersion)
            + " Build: " +
            (Constants.appBuildVersion)
        #if DEBUG
            ret = "👾 \(ret) 👾"
        #endif
        return ret
    }

    var body: some View {
        ZStack {
            ColorfulView(colorCount: 4)
                .ignoresSafeArea()
            VStack(spacing: 4) {
                Image("Avatar")
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)

                Spacer().frame(height: 16)

                Text("Welcome to PhotosProcessor")
                    .font(.system(.headline, design: .rounded))
                Text("A multi-functional picture processor software.")
                    .font(.system(.body, design: .rounded))

                Spacer().frame(height: 24)
            }
            VStack {
                Spacer()
                Text(version)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.5)
            }
            .padding()
        }
        .toolbar {
            Group {}
        }
        .frame(minWidth: 400, minHeight: 200)
        .navigationTitle("PhotosProcessor")
        .usePreferredContentSize()
    }
}
