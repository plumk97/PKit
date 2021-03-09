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
    var doubleTapGesture: UITapGestureRecognizer!
    
    override func commInit() {
        super.commInit()
    
        self.imageView = YYAnimatedImageView()
        self.contentView.addSubview(self.imageView)
        self.scrollView.maximumZoomScale = 5
        
        self.doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapGestureHandle(_ :)))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(self.doubleTapGesture)
        
        self.singleTapGesture.require(toFail: self.doubleTapGesture)
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
    
    override func loadResource() {
        super.loadResource()
        
        if let x = self.media.pl_thumbnail {
            self.showLoadingIndicator()
            self.parseData(data: x) {[weak self] (image) in
                self?.hideLoadingIndicator()
                if self?.imageView.image == nil, let image = image {
                    self?.imageView.image = image
                    self?.update()
                }
            }
        }
        
        if let x = self.media.pl_data {
            self.showLoadingIndicator()
            self.parseData(data: x) {[weak self] (image) in
                self?.hideLoadingIndicator()
                if self?.imageView.image == nil, let image = image {
                    self?.imageView.image = image
                    self?.update()
                }
            }
        }
    }
    
    func parseData(data: PLMediaData, complete: ((UIImage?)->Void)?) {
        
        switch data {
        case let x as UIImage:
            complete?(x)
            
        case let x as URL:
            self.parseURL(x, complete: complete)
        
        case let x as String:
            guard let url = URL.init(string: x) else {
                complete?(nil)
                return
            }
            self.parseURL(url, complete: complete)
            
        case let x as Data:
            complete?(YYImage.init(data: x))
            
        case let x as PHAsset:
            let op = PHImageRequestOptions()
            op.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: x, targetSize: .zero, contentMode: .default, options: op) { (image, _) in
                DispatchQueue.main.async {
                    complete?(image)
                }
            }
            
        default:
            break
        }
    }
    
    func parseURL(_ url: URL, complete: ((UIImage?)->Void)?) {
        if url.isFileURL {
            guard let data = try? Data.init(contentsOf: url) else {
                return
            }
            complete?(YYImage.init(data: data))
            return
        }
        self.media.pl_mediaDownload(url) { (obj) in
            complete?(obj as? UIImage)
        }
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
