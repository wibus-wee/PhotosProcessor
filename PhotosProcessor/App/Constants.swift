//
//  Constants.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import Foundation

enum Constants {
    static let appName = "PhotosProcessor"
    static let authorHomepageUrl = URL(string: "https://github.com/wibus-wee")!
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    static let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    static let projectUrl = URL(string: "https://github.com/wibus-wee/PhorosProcessor")!
}
