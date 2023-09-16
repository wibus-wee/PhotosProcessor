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
      .frame(minWidth: 600, minHeight: 400)
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
          presentationMode.wrappedValue.dismiss()
        }) {
          Text("Copy")
        }
        .keyboardShortcut("c", modifiers: [.command, .shift])
        .disabled(isRunning)
      }
    }
    .padding()
    .frame(minWidth: 600, minHeight: 400)
  }
}
