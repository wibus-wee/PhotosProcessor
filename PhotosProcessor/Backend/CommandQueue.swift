//
//  CommandQueue.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/17.
//

import SwiftUI


struct Command {
    let id: UUID
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
    

    func enqueue(_ command: String, _ arguments: [String], description: String) -> UUID {
        let newCommand = Command(id: UUID(), command: command, arguments: arguments, description: description)
        commands.append(newCommand)
        return newCommand.id
    }

    func execute(id: UUID) {
        guard commands.first(where: { $0.id == id }) != nil else {
            return
        }
        let _executor = Executor()
        let commandIndex = commands.firstIndex(where: { $0.id == id })!
        let command = commands[commandIndex].command
        let arguments = commands[commandIndex].arguments
        _executor.executeAsync(command, arguments)
        let commandResults = CommandResult(id: id, info: commands[commandIndex], executor: _executor)
        self.commandResults.append(commandResults)
        commands.remove(at: commandIndex)
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
        commands.remove(at: commandIndex)
    }

    func cancelAll() {
        commands.removeAll()
    }
    

}
