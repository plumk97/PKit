//
//  CGSize+Fit.swift
//  PKit
//
//  Created by 李铁柱 on 2023/12/12.
//

import Foundation

extension CGSize {
    
    public func fitSize(targetSize: CGSize) -> CGSize {
        let ratio = min(targetSize.width / self.width, targetSize.height / self.height)
        let newSize = CGSize.init(width: Int(self.width * ratio), height: Int(self.height * ratio))
        return newSize
    }
    
}
