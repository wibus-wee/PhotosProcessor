//
//  NonSmartNSTextView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/29.
//

import SwiftUI

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            self.isAutomaticQuoteSubstitutionEnabled = false
            self.isAutomaticDashSubstitutionEnabled = false
        }
    }
}
