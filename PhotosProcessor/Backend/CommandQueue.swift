//
//  CommandQueue.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/17.
//

import SwiftUI


struct Command {
    let id: UUID
    let parentId: UUID?
    let children: [UUID] = []
    let command: String
    let arguments: [String]
    let description: String
}

struct CommandResult {
    let id: UUID
    let info: Command
    let executor: Executor
}


class CommandQueue: ObservableObject {
    static let share = CommandQueue()

    @Published var commands: [Command] = []
    @Published var commandResults: [CommandResult] = []
    

    func enqueue(_ command: String, _ arguments: [String], parentId: UUID, description: String) -> UUID {
        let parentCommandIndex = commands.firstIndex(where: { $0.id == parentId })!
        let parentCommand = commands[parentCommandIndex]
        let newCommand = Command(id: UUID(), command: command, arguments: arguments, description: description, parentId: parentCommand.id)
        commands.append(newCommand)
        commands[parentCommandIndex].children.append(newCommand.id)
        return newCommand.id
    }

    /// You can use this method to enqueue a command with the parent command and children commands
    func execute(id: UUID) {
        guard commands.first(where: { $0.id == id }) != nil else {
            return
        }
        let _executor = Executor()
        let commandIndex = commands.firstIndex(where: { $0.id == id })!
        let _command = commands[commandIndex] // The current command
        var parentCommand = _command
        while parentCommand.parentId != nil {
            let parentCommandIndex = commands.firstIndex(where: { $0.id == parentCommand.parentId })!
            parentCommand = commands[parentCommandIndex]
        }
        // Find the top-level parent, then execute creating a command, argument array, and then execute
        var commandArray: [(command: String, arguments: [String])] = []
        commandArray.append((parentCommand.command, parentCommand.arguments))
        var times = 0
        func executeChildren(_ command: Command) {
            while times < 10 {
                for childId in command.children {
                    let childCommandIndex = commands.firstIndex(where: { $0.id == childId })!
                    let childCommand = commands[childCommandIndex]
                    commandArray.append((childCommand.command, childCommand.arguments))
                    executeChildren(childCommand) // Recursion
                }
                times += 1
            }
            if times > 10 {
                fatalError("Recursion times is over 10. This is a bug. Please report it to the developer.")
            }
        }
        executeChildren(parentCommand)
        _executor.executeMultiInOneAsync(commandArray)
    }

    func findOne(id: UUID?) -> CommandResult? {
        guard let id = id else {
            return nil
        }
        guard commandResults.first(where: { $0.id == id }) != nil else {
            return nil
        }
        let commandResultIndex = commandResults.firstIndex(where: { $0.id == id })!
        return commandResults[commandResultIndex]
    }

    func cancel(id: UUID) {
        guard commands.first(where: { $0.id == id }) != nil else {
            return
        }
        let commandIndex = commands.firstIndex(where: { $0.id == id })!
        let command = commands[commandIndex]
        // Remove the id in the children of the parent
        let parentCommand = commands.first(where: { $0.id == command.parentId })!
        let parentCommandIndex = commands.firstIndex(where: { $0.id == command.parentId })!
        let parentCommandChildrenIndex = parentCommand.children.firstIndex(where: { $0 == id })!
        commands[parentCommandIndex].children.remove(at: parentCommandChildrenIndex)
        // Remove all children
        for childId in command.children {
            let childCommandIndex = commands.firstIndex(where: { $0.id == childId })!
            let childCommand = commands[childCommandIndex]
            cancel(id: childCommand.id)
        }
        // Remove the command
        commands.remove(at: commandIndex)
        
    }

    func cancelAll() {
        commands.removeAll()
    }
    

}
