//
//  InternalKit.swift
//  SoftwareHelper
//
//  Created by wibus on 2023/8/19.
//

import SwiftUI

enum InternalKit {
    typealias IsClickPrimaryButton = Bool
    
    struct AnySheetView: View {
        @Environment(\.dismiss) var dismiss // dismiss the sheet
        let title: String
        let secondaryButton: String
        let primaryButton: String
        let toolbar: (() -> (AnyView))?
        let content: (() -> (AnyView))
        let action: (IsClickPrimaryButton) -> Void
        
        init(
            title: String,
            secondaryButton: String,
            primaryButton: String,
            toolbar: (() -> (AnyView))? = nil,
            content: @escaping () -> AnyView,
            action: @escaping (IsClickPrimaryButton) -> Void
        ) {
            self.title = title
            self.secondaryButton = secondaryButton
            self.primaryButton = primaryButton
            self.toolbar = toolbar
            self.content = content
            self.action = action
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if title.isEmpty, toolbar == nil {
                } else {
                    HStack {
                        Text(title).font(.headline)
                        Spacer()
                        if let toolbar { toolbar() }
                    }
                    Divider()
                }
                content().frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                HStack {
                    if !secondaryButton.isEmpty {
                        Button { action(false) } label: { Text(secondaryButton) }
                    }
                    Spacer()
                    if !primaryButton.isEmpty {
                        Button { action(true) } label: { Text(primaryButton) }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .background(
                    Button("") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                        .opacity(0)
                )
            }
            .padding()
        }
    }
    
    static func useSheet(
        title: String,
        secondaryButton: String = "Cancel",
        primaryButton: String = "OK",
        toolbar: (() -> (AnyView))? = nil,
        content: @escaping () -> AnyView,
        action: @escaping (IsClickPrimaryButton) -> Void?
    ) -> some View {
        AnySheetView(
            title: title,
            secondaryButton: secondaryButton,
            primaryButton: primaryButton,
            toolbar: toolbar,
            content: content,
            action: { isClickPrimaryButton in
                action(isClickPrimaryButton)
            }
        )
    }
    
    static func useAlert(
        title: String,
        message: String,
        primaryButton: String = "OK",
        secondaryButton: String = "Cancel",
        action: @escaping (IsClickPrimaryButton) -> Void?
    ) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: primaryButton)
        alert.addButton(withTitle: secondaryButton)
        alert.alertStyle = .informational
        alert.beginSheetModal(for: NSApp.mainWindow!) { response in
            action(response == .alertFirstButtonReturn)
        }
    }
    
    static func useFilePanel(
        title: String,
        message: String,
        primaryButton: String = "OK",
        secondaryButton: String = "Cancel",
        action: @escaping (URL?) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.title = title
        panel.message = message
        panel.prompt = primaryButton
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: NSApp.mainWindow!) { response in
            action(panel.url)
        }
    }
    
    static func setupSettingView(
        title: String,
        field: String,
        text: String,
        disabled: Bool?,
        firstButton: String?,
        firstButtonAction: (() -> Void)?,
        secondButton: String?,
        secondButtonAction: (() -> Void)?,
        description: String?
    ) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                HStack {
                    TextField(field, text: .constant(text))
                        .disabled(disabled ?? false)
                    if (firstButton != nil) {
                        Button(firstButton!) {
                            firstButtonAction?()
                        }
                    }
                    if (secondButton != nil) {
                        Button(secondButton!) {
                            secondButtonAction?()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                if(description != nil) {
                    Text(description!)
                        .font(.system(.footnote))
                }
            }
    }
    
}
