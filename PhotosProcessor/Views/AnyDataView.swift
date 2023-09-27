//
//  AnyDataView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/27.
//

import SwiftUI

struct AnyDataView: View {
  @Environment(\.presentationMode) var presentationMode
  @Binding var title: String
  @Binding var data: Any?

  var body: some View {
    VStack {
      HStack {
        Text(title)
          .font(.system(.title, design: .rounded, weight: .bold))
        Spacer()
        if data != nil {
          Text("Type: \(String(describing: type(of: data!)))")
            .font(.system(.caption, design: .rounded))
            .foregroundColor(.secondary)
        }
      }
      ScrollView {
        Text("\(String(describing: data))")
          .font(.system(.caption, design: .monospaced))
      }
      HStack {
        Spacer()
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          Text("Close")
        }
        .keyboardShortcut(.defaultAction)
        Button(action: {
          let pasteboard = NSPasteboard.general
          pasteboard.clearContents()
          pasteboard.setString("\(String(describing: data))", forType: .string)
        }) {
          Text("Copy")
        }
        .keyboardShortcut("c", modifiers: [.command])
      }
    }
    .padding()
    .frame(minWidth: 400, minHeight: 300)
  }
}
