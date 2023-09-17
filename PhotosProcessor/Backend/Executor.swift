//
//  Executor.swift
//  Action
//
//  Created by wibus on 2023/9/17.
//

import Foundation

class Executor: ObservableObject {
    @Published var outputText = ""
    @Published var errorMessage = ""
    @Published var isRunning = false

    
    init() {
        let whoami = "/usr/bin/whoami"
        let receipt =  execute(whoami, [])
        let username = receipt.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard receipt.exitCode == 0, !username.isEmpty /* , username != "root" */ else {
            fatalError("Malformed application permissions.")
        }
        print("[*] whoami \(username)")
    }
    
    func isCommandAvailable(_ command: String) -> (status: Bool, path: String) {
        let executeResult = execute("/usr/bin/which", [command])
        if executeResult.exitCode == 0 {
            return (true, executeResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            return (false, "")
        }
    }
    
    func executeAsync(_ command: String, _ arguments: [String]) {
        var launchPathpath = ""
        let commandAvailable = isCommandAvailable(command)
        guard commandAvailable.status else {
            DispatchQueue.main.async {
                self.errorMessage += "Command \(command) not found.\n"
            }
            return
        }
        launchPathpath = commandAvailable.path
        DispatchQueue.global(qos: .background).async {
            let task = Process()
            let pipe = Pipe()
            let errorPipe = Pipe() // Add an error pipe
            task.standardOutput = pipe
            task.launchPath = launchPathpath
            task.arguments = arguments
            
            let outputHandler = pipe.fileHandleForReading
            outputHandler.readabilityHandler = { pipe in
                let data = pipe.availableData
                if let output = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.outputText += output
                    }
                }
            }
            
            let errorHandler = errorPipe.fileHandleForReading
            errorHandler.readabilityHandler = { pipe in
                let data = pipe.availableData
                if let error = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.errorMessage += error
                    }
                }
            }
            
            task.terminationHandler = { _ in
                outputHandler.closeFile()
                errorHandler.closeFile()
                DispatchQueue.main.async {
                    self.isRunning = false
                }
            }
            
            task.launch()
            print("[*] \(command) \(arguments.joined(separator: " "))")
            self.isRunning = true
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                DispatchQueue.main.async {
                    self.errorMessage += "Command failed with exit code \(task.terminationStatus)\n"
                }
            }
        }
    }

    func executeMultiInOneAsync(_ commands: [(command: String, arguments: [String])]) {
        for command in commands {
            executeAsync(command.command, command.arguments)
        }
    }
    
    
    func clean() {
        outputText = ""
        errorMessage = ""
        isRunning = false
    }
    
    func execute(_ command: String, _ arguments: [String]) -> (exitCode: Int32, stdout: String, stderr: String) {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = command
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        return (task.terminationStatus, output, "")
    }
}
