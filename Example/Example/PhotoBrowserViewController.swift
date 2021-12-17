//
//  PhotoBrowserViewController.swift
//  PKit
//
//  Created by Plumk on 2019/5/16.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import Photos
import PKit

class PhotoBrowserViewController: UIViewController {

    struct Media: PKUIMedia {
        let isImage: Bool
        let vc: PhotoBrowserViewController
        let src: PKUIMediaData
        let thumbnail: PKUIMediaData?
        
        var pl_pageClass: PKUIMediaBrowserPage.Type {
            return self.isImage ? PKUIMediaBrowserImagePage.self : PKUIMediaBrowserVideoPage.self
        }
        
        var pl_data: PKUIMediaData? { self.src }
        var pl_thumbnail: PKUIMediaData? { self.thumbnail }
        
        func pl_mediaDownload(_ url: URL, complete: @escaping (Any?) -> Void) {
            self.vc.loadImage(url: url.absoluteString) {
                complete($0)
            }
        }
        
        
        
    }
    
    
    var imageCache = NSCache<NSString, UIImage>()
    var urls = [String]()
    var assets = [PHAsset]()
    
    var gridView: PKUIGridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PhotoBrowserViewController"
        
        // https://vd2.bdstatic.com/mda-kj9yrgneyh6n01xy/sc/mda-kj9yrgneyh6n01xy.mp4
        // https://vdposter.bdstatic.com/edcea657acd4dd434601e51c0ec5b041.jpeg?x-bce-process=image/resize,m_fill,w_352,h_234/format,f_jpg/quality,Q_100
        let plainText = try! String.init(contentsOfFile: Bundle.main.path(forResource: "imagesrc", ofType: "text")!)
        self.urls = plainText.components(separatedBy: "\n").filter({ $0.count > 0 })
        
        self.gridView = PKUIGridView(self.urls.enumerated().map({[unowned self] in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = $0.offset + 10
            self.loadImage(url: $0.element) { (x) in
                imageView.image = x
            }
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imageViewTapGestureHandle(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.isUserInteractionEnabled = true
            
            return imageView
        }), crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10)
        
        if true {
            // 加入视频
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = self.urls.count + 10
            self.gridView.views.append(imageView)
            
            self.loadImage(url: "https://vdposter.bdstatic.com/edcea657acd4dd434601e51c0ec5b041.jpeg?x-bce-process=image/resize,m_fill,w_352,h_234/format,f_jpg/quality,Q_100") { (image) in
                imageView.image = image
            }
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imageViewTapGestureHandle(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.isUserInteractionEnabled = true
        }
        
        if true {
            
            let ret = PHAsset.fetchAssets(with: nil)
            let count = ret.count > 10 ? 10 : ret.count
            for i in 0 ..< count {
                self.assets.append(ret.object(at: i))
            }
            
            self.gridView.views.append(contentsOf: self.assets.enumerated().map({[unowned self] in
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.tag = $0.offset + 10 + self.gridView.views.count
                
                let op = PHImageRequestOptions()
                op.deliveryMode = .fastFormat
                PHImageManager.default().requestImage(for: $0.element, targetSize: .zero, contentMode: .default, options: op) { (iamge, _) in
                    DispatchQueue.main.async {
                        imageView.image = iamge
                    }
                }
                
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imageViewTapGestureHandle(_:)))
                imageView.addGestureRecognizer(tap)
                imageView.isUserInteractionEnabled = true
                
                return imageView
            }))
        }
        
        self.gridView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.gridView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[view]-20-|", options: [], metrics: nil, views: ["view": self.gridView!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[view]", options: [], metrics: nil, views: ["view": self.gridView!]))
    }

    func loadImage(url: String, complete: ((UIImage?)->Void)?) {
        
        let key = url as NSString
        if let image = self.imageCache.object(forKey: key) {
            complete?(image)
            return
        }
        
        guard let uurl = URL.init(string: url) else {
            return
        }
        
        URLSession.shared.downloadTask(with: uurl, completionHandler: {[weak self] (fileurl, response, error) in
            
            var image: UIImage?
            defer {
                DispatchQueue.main.async {
                    if let x = image {
                        self?.imageCache.setObject(x, forKey: key)
                    }
                    complete?(image)
                }
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            guard fileurl != nil else {
                return
            }
            
            guard let data = try? Data.init(contentsOf: fileurl!) else {
                return
            }
            
            guard let x = UIImage.init(data: data) else {
                return
            }
            
            image = x
        }).resume()
    }
    
    @objc func imageViewTapGestureHandle(_ sender: UITapGestureRecognizer) {
        guard let x = sender.view as? UIImageView else {
            return
        }
        
        var mediaArray: [PKUIMedia] = self.urls.map({
            return Media.init(isImage: true, vc: self, src: $0, thumbnail: nil)
        })
        
        let m = Media.init(isImage: false, vc: self, src: "https://vd2.bdstatic.com/mda-kj9yrgneyh6n01xy/sc/mda-kj9yrgneyh6n01xy.mp4", thumbnail: "https://vdposter.bdstatic.com/edcea657acd4dd434601e51c0ec5b041.jpeg?x-bce-process=image/resize,m_fill,w_352,h_234/format,f_jpg/quality,Q_100")
        mediaArray.append(m)

        mediaArray.append(contentsOf: self.assets.map({
            return Media.init(isImage: $0.mediaType == .image, vc: self, src: $0, thumbnail: nil)
        }))
        
        let browser = PKUIMediaBrowser.init(mediaArray: mediaArray, initIndex: x.tag - 10, fromImageView: x)
        browser.didChangePageCallback = { browser, idx in
            browser.fromImageView = self.gridView.viewWithTag(idx + 10) as? UIImageView
        }
        self.present(browser, animated: true, completion: nil)
    }
}
