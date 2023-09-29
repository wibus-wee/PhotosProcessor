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
    // var cleanExifInfo: Bool
    // var useColorProfiles: Bool
    // var colorProfile: String?
}

class Compressor {
    func avifencCommand(imagePath: String, config: CompressorConfig) -> (command: String, arguments: [String])? {
      var avifencPath = ""
      if (configuration.avifencLocationType == "built-in") {
          avifencPath = Bundle.main.path(forResource: "avifenc", ofType: nil)!
      } else {
        avifencPath = configuration.avifencLocation
      }
        if avifencPath == nil || avifencPath.isEmpty {
        InternalKit.useAlert(
          title: "Avifenc Not Found",
          message: "Please check if avifenc is installed, or set the location type to Built-in in the settings",
          primaryButton: "OK",
          secondaryButton: "Cancel"
        ) { _ in }
        return nil
      }
      let type = imagePath.components(separatedBy: ".").last
      let avifImagePath = imagePath.replacingOccurrences(of: type!, with: "avif")
      let arguments = [
//        "--qcolor", "\(config.quality)",
//        "--qalpha", "\(config.quality)",
        "--speed", "\(config.speed)",
        "--yuv", "\(config.yuv)",
        imagePath,
        avifImagePath
      ]
      
        return (avifencPath, arguments)
    }

    // @WIP
    func metadataProcess(imagePath: String, config: CompressorConfig) -> (command: String, arguments: [String])? {
      let exiftoolPath = Bundle.main.path(forResource: "exiftool", ofType: nil)
      if exiftoolPath == nil || exiftoolPath!.isEmpty {
        InternalKit.useAlert(
          title: "无法找到 exiftool",
          message: "请检查 exiftool 是否已安装",
          primaryButton: "OK",
          secondaryButton: "Cancel"
        ) { _ in }
        return nil
      }
      let arguments = [
        "-all:all=",
        imagePath
      ]
      return (exiftoolPath!, arguments)
      
    }

    // @WIP
//    func profileProcess(imagePath: String, config: CompressorConfig) -> (command: String, arguments: [String])? {
//      let magickPath = Bundle.main.path(forResource: "magick", ofType: nil)
//      if magickPath == nil || magickPath!.isEmpty {
//        InternalKit.useAlert(
//          title: "无法找到 magick",
//          message: "请检查 magick 是否已安装",
//          primaryButton: "OK",
//          secondaryButton: "Cancel"
//        ) { _ in }
//        return nil
//      }
//      let colorProfilePath = "/System/Library/ColorSync/Profiles/" + config.colorProfile!
//      let arguments = [
//        imagePath,
//        "-profile",
//        colorProfilePath,
//        imagePath
//      ]
//      return (magickPath!, arguments)
//    }
}
