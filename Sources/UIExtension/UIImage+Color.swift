//
//  UIImage+Color.swift
//  PKit
//
//  Created by plumk on 2024/12/26.
//

import UIKit

public extension UIImage {
    
    convenience init(color: UIColor, size: CGSize = .init(width: 1, height: 1)) {
        let render = UIGraphicsImageRenderer(size: size)
        let image = render.image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: size))
        }
        if let cgImage = image.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
    }
}
