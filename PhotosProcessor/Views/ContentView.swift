//
//  ContentView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

struct ContentView: View {
    @State private var isStatusPopoverShown = false
    @State var showingLogSheetID = ""
    
    init() {
        let url = URL(fileURLWithPath: "/System/Library/ColorSync/Profiles")
        let _ = url.startAccessingSecurityScopedResource()
    }
    
    var body: some View {
        NavigationView {
            List {
                SidebarView()
            }
            .listStyle(.sidebar)
            .navigationTitle(Constants.appName)
            WelcomeView()
        }
        .sheet(isPresented: Binding(
            get: {
                showingLogSheetID != ""
            },
            set: { newValue in
                if !newValue {
                    showingLogSheetID = ""
                }
            }
        )) {
            LogView(id: $showingLogSheetID)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)),
                        with: nil
                    )
                } label: {
                    Label("Toggle Sidebar", systemImage: "sidebar.leading")
                }
            }
            
            ToolbarItem {
                Button {
                    self.isStatusPopoverShown.toggle()
                } label: {
                    Label("Queue", systemImage: "list.bullet.rectangle")
                }
                .popover(isPresented: self.$isStatusPopoverShown, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {

                        Text("Queue List")
                        Text(
                            "There are \(commandQueue.commands.count) commands in the queue."
                        )
                        .foregroundColor(.secondary)

                        ForEach(commandQueue.commands, id: \.id) { command in
                            Divider()
                            VStack {
                                Text("\(command.description)")
                                .font(.system(.body, design: .rounded))
                                Text("\(command.id)")
                                    .foregroundColor(.secondary)
                                    .font(.system(.caption, design: .monospaced))
                                List {
                                    ForEach(command.children, id: \.self) { childId in
                                        let childCommand = commandQueue.commands.first(where: { $0.id == childId })!
                                        Text("\(childCommand.description) (Child)")
                                            .font(.system(.body, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                
                                HStack {
                                    Button("Execute") {
                                        commandQueue.execute(id: command.id)
                                        isStatusPopoverShown = false
                                    }
                                    .buttonStyle(.borderedProminent)
                                    Button("Cancel") {
                                        commandQueue.cancel(id: command.id)
                                        isStatusPopoverShown = false
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        ForEach(commandQueue.commandResults, id: \.id) { commandResult in
                            Divider()
                            VStack {
                                Text("\(commandResult.info.description)")
                                .font(.system(.body, design: .rounded))
                                Text("\(commandResult.id) (Executed)")
                                    .foregroundColor(.secondary)
                                    .font(.system(.caption, design: .monospaced))
                                Spacer()
                                
                                HStack {
                                    Button("Show Log") {
                                        showingLogSheetID = commandResult.id.uuidString
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }


                    }
                    .padding()
                }
            }
        }
    }
}
