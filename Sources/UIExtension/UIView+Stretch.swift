//
//  UIView+Stretch.swift
//  PKit
//
//  Created by plumk on 2024/12/18.
//

import UIKit


public extension UIView {
    
    func disableStretch() {
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
