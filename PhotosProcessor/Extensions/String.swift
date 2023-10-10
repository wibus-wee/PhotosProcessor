//
//  String.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/10/10.
//

import Foundation

extension String {
    func toBinary() -> String {
        return self.reduce("") {
            let s = String(Int(String($1).unicodeScalars.first!.value), radix: 2)
            return $0 + String(repeating: "0", count: 8 - s.count) + s
        }
    }

    func fromBinary() -> String {
        var result = ""
        var index = self.startIndex
        while index < self.endIndex {
            let nextIndex = self.index(index, offsetBy: 8)
            let char = self[index..<nextIndex]
            let s = String(Int(char, radix: 2)!, radix: 10)
            result += String(UnicodeScalar(UInt8(s)!))
            index = nextIndex
        }
        return result
    }
}

