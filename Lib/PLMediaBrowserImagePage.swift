//
//  PLMediaBrowserImagePage.swift
//  PLKit
//
//  Created by mini2019 on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import YYImage
import Photos

class PLMediaBrowserImagePage: PLMediaBrowserPage {

    override var coverImage: UIImage? {
        return self.imageView.image
    }
    
    var imageView: UIImageView!
    
    override func commInit() {
        super.commInit()
    
        self.imageView = YYAnimatedImageView()
        self.contentView.addSubview(self.imageView)
        self.scrollView.maximumZoomScale = 5
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapGestureHandle(_ :)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        self.singleTapGesture.require(toFail: doubleTap)
    }
    
    override func singleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
        super.singleTapGestureHandle(sender)
    }
    
    @objc func doubleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        guard self.imageView.image != nil else {
            return
        }
        
        if sender.state == .ended {
            guard self.scrollView.maximumZoomScale > self.scrollView.minimumZoomScale else {
                return
            }
            
            if self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
                self.scrollView.zoom(to: .init(origin: sender.location(in: self), size: .zero), animated: true)
            } else {
                self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
            }
        }
    }

    override func reloadData() {
        guard let media = self.media else {
            return
        }
        
        if let x = media.thumbnail {
            self.parseData(data: x)
        }
        
        if let x = media.data {
            self.parseData(data: x)
        }
    }
    
    func parseData(data: PLMediaData) {
        
        switch data {
        case let x as UIImage:
            self.imageView.image = x
            self.update()
            
        case let x as URL:
            self.parseURL(x)
        
        case let x as String:
            guard let url = URL.init(string: x) else {
                return
            }
            self.parseURL(url)
            
        case let x as Data:
            self.imageView.image = YYImage.init(data: x)
            self.update()
            
        case let x as PHAsset:
            break
            
        default:
            break
        }
    }
    
    func parseURL(_ url: URL) {
        if url.isFileURL {
            guard let data = try? Data.init(contentsOf: url) else {
                return
            }
            self.imageView.image = YYImage.init(data: data)
            self.update()
            return
        }
        
        self.media?.imageDownloadCallback?(url, {[weak self] image in
            if let x = image {
                self?.imageView.image = x
            }
            self?.update()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !self.closeGesture.isRunning else {
            return
        }
        self.update()
    }
    
    func update(isReset: Bool = true) {
        defer {
            self.imageView.frame = self.contentView.bounds
        }
        
        guard !self.bounds.size.equalTo(.zero) else {
            return
        }
        
        guard let image = self.imageView.image else {
            self.contentView.frame = .zero
            return
        }
        
        var imageSize = type(of: self).fitSize(image.size, targetSize: self.bounds.size)
        
        var rect: CGRect = .zero
        if isReset && self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
            rect.size = imageSize
            
            self.scrollView.contentSize = .init(width: max(self.bounds.width, imageSize.width),
                                                height: max(self.bounds.height, imageSize.height))
        } else {
            imageSize.width *= self.scrollView.zoomScale
            imageSize.height *= self.scrollView.zoomScale
            rect.size = imageSize
        }
        
        let contentSize = self.scrollView.contentSize
        
        rect.origin = .init(x: (max(contentSize.width, self.bounds.width) - imageSize.width) / 2,
                            y: (max(contentSize.height, self.bounds.height) - imageSize.height) / 2)
        self.contentView.frame = rect
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.update(isReset: false)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView.image == nil ? nil : self.contentView
    }
}
