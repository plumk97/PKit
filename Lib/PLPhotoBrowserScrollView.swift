//
//  PLPhotoBrowserScrollView.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLPhotoBrowserScrollView: UIScrollView {
    
    var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.reset()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView.init(frame: .zero)
        self.addSubview(self.imageView)
        
        self.delegate = self
        self.minimumZoomScale = 1
        self.maximumZoomScale = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func reset() {
        self.zoomScale = self.minimumZoomScale
        self.update()
    }
    
    func update() {
        
        guard let image = self.imageView.image else {
            return
        }
        
        var imageSize = image.size
        
        let ratio = min(1, min(self.bounds.width / imageSize.width, self.bounds.height / imageSize.height))
        
        imageSize.width *= ratio
        imageSize.height *= ratio
        
        imageSize.width *= self.zoomScale
        imageSize.height *= self.zoomScale
        
        self.imageView.frame.size = imageSize
        
        let width = max(self.bounds.width, self.contentSize.width)
        let height = max(self.bounds.height, self.contentSize.height)
        print(self.contentSize)
        self.imageView.frame.origin = .init(x: (width - imageSize.width) / 2, y: (height - imageSize.height) / 2)
    }
}

extension PLPhotoBrowserScrollView: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.update()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
