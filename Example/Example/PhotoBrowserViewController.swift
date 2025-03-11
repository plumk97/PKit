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
        
        var pk_pageClass: PKUIMediaBrowserPage.Type {
            self.isImage ? PKUIMediaBrowserImagePage.self : PKUIMediaBrowserVideoPage.self
        }
        
        var pk_data: PKUIMediaData? { self.src }
        var pk_thumbnail: PKUIMediaData? { self.thumbnail }
        
        func pk_downloadImage(_ url: URL, complete: @escaping (UIImage?) -> Void) {
            self.vc.downloadImage(url: url, complete: complete)
        }
    }
    
    var medias = [Media]()
    var resources = [Any]()
    var gridView: PKUIGridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PhotoBrowserViewController"
        
        self.setupResources()
        self.gridView = PKUIGridView(self.resources.enumerated().map({[unowned self] in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = $0.offset
            self.loadResource($0.element, imageView: imageView)
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imageViewTapGestureHandle(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.isUserInteractionEnabled = true
            
            return imageView
        }), crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10)
        
        self.gridView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.gridView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[view]-20-|", options: [], metrics: nil, views: ["view": self.gridView!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[view]", options: [], metrics: nil, views: ["view": self.gridView!]))
    }
    
    func setupResources() {
        let plainText = try! String.init(contentsOfFile: Bundle.main.path(forResource: "imagesrc", ofType: "text")!)
        let urls = plainText.components(separatedBy: "\n").filter({ $0.count > 0 })
        for url in urls {
            self.medias.append(.init(isImage: true, vc: self, src: url, thumbnail: nil))
        }
        self.resources.append(contentsOf: urls)
        
        let ret = PHAsset.fetchAssets(with: nil)
        let count = ret.count > 10 ? 10 : ret.count
        for i in 0 ..< count {
            let asset = ret.object(at: i)
            self.medias.append(.init(isImage: true, vc: self, src: asset, thumbnail: nil))
            self.resources.append(ret.object(at: i))
        }
        
        self.resources.append("https://vdposter.bdstatic.com/edcea657acd4dd434601e51c0ec5b041.jpeg?x-bce-process=image/resize,m_fill,w_352,h_234/format,f_jpg/quality,Q_100")
        self.medias.append(.init(isImage: false, vc: self, src: "https://vd2.bdstatic.com/mda-kj9yrgneyh6n01xy/sc/mda-kj9yrgneyh6n01xy.mp4", thumbnail: nil))
    }
    
    func loadResource(_ resource: Any, imageView: UIImageView) {
        
        switch resource {
        case let urlstr as String:
            guard let url = URL.init(string: urlstr) else {
                return
            }
            self.downloadImage(url: url) {[weak imageView] image in
                DispatchQueue.main.async {
                    imageView?.image = image
                }
            }
            
        case let asset as PHAsset:
            let option = PHImageRequestOptions()
            option.resizeMode = .fast
            option.deliveryMode = .fastFormat
            PHImageManager.default().requestImage(for: asset, targetSize: .init(width: 100, height: 100), contentMode: .aspectFit, options: option) {[weak imageView] image, _ in
                DispatchQueue.main.async {
                    imageView?.image = image
                }
            }
        default:
            break
        }
        
    }
    
    func downloadImage(url: URL, complete: @escaping (UIImage?) -> Void) {
        URLSession.shared.downloadTask(with: url, completionHandler: { (fileurl, response, error) in

            guard let fileurl = fileurl,
                  let data = try? Data.init(contentsOf: fileurl),
                  let image = UIImage.init(data: data)else {
                complete(nil)
                return
            }
            
            complete(image)
        }).resume()
    }

    
    @objc func imageViewTapGestureHandle(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
 
        let browser = PKUIMediaBrowser.init(medias: self.medias, defaultIndex: imageView.tag)
        browser.transitioningView = { browser in
            return self.gridView.views[browser.currentPageIndex]
        }
        
        browser.indexChanged = { browser in
            
        }
        self.present(browser, animated: true)
    }
}
