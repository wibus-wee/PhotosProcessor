//
//  WelcomeView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//


import SwiftUI

struct WelcomeView: View {

    var body: some View {
        ZStack {
            VStack {
                Image("Avatar")
                    .resizable()
                    .antialiased(true)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80, alignment: .center)
                Text("Welcome to PhotosProcessor")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Rectangle()
                    .frame(width: 100, height: 20, alignment: .center)
                    .opacity(0)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Made with love by @wibus-wee - v\(Constants.appVersion).b\(Constants.appBuildVersion)")
                        .onTapGesture {
                            NSWorkspace.shared.open(Constants.authorHomepageUrl)
                        }
                }
                .font(.system(.caption, design: .rounded, weight: .bold))
                .opacity(0.55)
            }
            .padding()

        }
        .toolbar {
            Group {
            }
        }
        .frame(minWidth: 400, minHeight: 200)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
