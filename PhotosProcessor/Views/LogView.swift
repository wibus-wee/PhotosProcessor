//
//  LogView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/17.
//

import SwiftUI

struct LogView: View {
  @Environment(\.presentationMode) var presentationMode
  @Binding var id: String
  @State private var commandResult: CommandResult? = nil

  init(id: Binding<String>) {
    _id = id
    let convertedID = UUID(uuidString: id.wrappedValue)
    let commandResult = commandQueue.findOne(id: convertedID)
    _commandResult = State(initialValue: commandResult)
}

  var body: some View {

    VStack {
      HStack {
        Text("Log")
          .font(.system(.title, design: .rounded, weight: .bold))
        Spacer()
        if commandResult != nil {
          Text("Status: \(commandResult!.executor.isRunning ? "Running" : "Finished")")
            .font(.system(.caption, design: .rounded))
            .foregroundColor(.secondary)
        }
      }
      ScrollView {
        Text(commandResult?.executor.outputText ?? "")
          .font(.system(.caption, design: .monospaced))
        if !commandResult!.executor.errorMessage.isEmpty {
          Text("Error: \(commandResult!.executor.errorMessage)")
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.red)
        }
      }
      HStack {
        Spacer()
        if commandResult!.executor.isRunning {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(0.5)
        }
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          Text("Close")
        }
        .keyboardShortcut(.defaultAction)
        Button(action: {
          let pasteboard = NSPasteboard.general
          pasteboard.clearContents()
          pasteboard.setString(commandResult!.executor.outputText, forType: .string)
          presentationMode.wrappedValue.dismiss()
        }) {
          Text("Copy")
        }
        .keyboardShortcut("c", modifiers: [.command, .shift])
      }
    }
    .padding()
    .frame(maxWidth: 800, maxHeight: 700)
  }
}

struct LogView_Previews: PreviewProvider {
  static var previews: some View {
    LogView(id: .constant("123"))
  }
}
