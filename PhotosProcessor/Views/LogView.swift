//
//  LogView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/17.
//

import SwiftUI

struct LogView: View {
  @Environment(\.presentationMode) var presentationMode
  @Binding var outputText: String
  @Binding var errorMessage: String
  @Binding var isRunning: Bool

  var body: some View {
    VStack {
      HStack {
        Text("Log")
          .font(.system(.title, design: .rounded, weight: .bold))
        Spacer()
      }
      ScrollView {
        Text(outputText)
          .font(.system(.body, design: .monospaced))
          .foregroundColor(.white)
        if !errorMessage.isEmpty {
          Text("Error: \(errorMessage)")
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.red)
        }
      }
      .frame(minWidth: 400, minHeight: 300)
      HStack {
        Spacer()
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          Text("Close")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(isRunning)
        Button(action: {
          let pasteboard = NSPasteboard.general
          pasteboard.clearContents()
          pasteboard.setString(outputText, forType: .string)
          presendationMode.wrappedValue.dismiss()
        }) {
          Text("Copy")
        }
      }
    }
    .padding()
    .frame(minWidth: 400, minHeight: 300)
  }
}
