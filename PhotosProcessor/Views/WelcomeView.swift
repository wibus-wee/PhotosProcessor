//
//  WelcomeView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//


import SwiftUI

struct WelcomeView: View {
    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @State var dotAnimation: String = ""
    @State var openInstanceDialog: Bool = false
    
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
//                    Text("Spiders Service is Running \(dotAnimation)")
                    Spacer()
                    Text("Made with love by @wibus-wee - v\(Constants.appVersion).b\(Constants.appBuildVersion)")
                        .onTapGesture {
                            NSWorkspace.shared.open(Constants.authorHomepageUrl)
                        }
                }
                .font(.system(.caption, design: .rounded, weight: .light))
                .opacity(0.75)
                .onReceive(timer) { _ in
                    switch dotAnimation {
                    case ".": dotAnimation = ".."
                    case "..": dotAnimation = "..."
                    case "...": dotAnimation = "...."
                    default: dotAnimation = "."
                    }
                }
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
