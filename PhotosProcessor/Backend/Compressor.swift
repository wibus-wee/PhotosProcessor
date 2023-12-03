//
//  Compressor.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import Foundation

struct CompressorConfig {
    var quality: Int
    var yuv: String
    var speed: Int
    var arguments: String?
    var output: String?
    // var cleanExifInfo: Bool
    // var useColorProfiles: Bool
    // var colorProfile: String?
}

class Compressor {
    func avifencCommand(imagePath: String, config: CompressorConfig) -> (command: String, arguments: [String], processedPath: String)? {
      var avifencPath = ""
      if (configuration.avifencLocationType == "built-in") {
          avifencPath = Bundle.main.path(forResource: "avifenc", ofType: nil)!
      } else {
        avifencPath = configuration.avifencLocation
      }
        if avifencPath.isEmpty {
        InternalKit.useAlert(
          title: "Avifenc Not Found",
          message: "Please check if avifenc is installed, or set the location type to Built-in in the settings",
          primaryButton: "OK",
          secondaryButton: "Cancel"
        ) { _ in }
        return nil
      }
      let type = imagePath.components(separatedBy: ".").last
      var avifImagePath = ""
      if (config.output != nil && !config.output!.isEmpty) {
        let avifImageName = imagePath.components(separatedBy: "/").last!.replacingOccurrences(of: type!, with: "avif")
        avifImagePath = config.output! + "/" + avifImageName
      } else {
        avifImagePath = imagePath.replacingOccurrences(of: type!, with: "avif")
      }
      var arguments = [
//        "--qcolor", "\(config.quality)",
//        "--qalpha", "\(config.quality)",
        "--speed", "\(config.speed)",
        "--yuv", "\(config.yuv)",
      ]
      if (config.arguments != nil && !config.arguments!.isEmpty) {
        arguments.append(contentsOf: config.arguments!.components(separatedBy: " "))
      }
      arguments.append(imagePath)
      arguments.append(avifImagePath)
      
      return (avifencPath, arguments, avifImagePath)
    }

    func compress(path: String, name: String, config: CompressorConfig) -> (id: UUID, processedPath: String)? {
        let compressCommand = self.avifencCommand(imagePath: path, config: config)
        if compressCommand == nil {
            return nil
        }
        let id = commandQueue.enqueue(compressCommand!.command, compressCommand!.arguments, description: "Compress \(name) to AVIF")
        // queueId = id
        // Configuration: Execute command immediately
        if configuration.executeImmediately {
            commandQueue.execute(id: id)
        }
        return (id, compressCommand!.processedPath)
    }
}
