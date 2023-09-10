//
//  ShellRunner.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import Foundation

class ShellRunner {
    
    func execute(command: String, arguments: [String]) -> String? {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        
        return output
    }
}
