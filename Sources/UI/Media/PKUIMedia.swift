//
//  PKUIMedia.swift
//  PKit
//
//  Created by Plumk on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import Photos

public protocol PKUIMediaData {}

extension UIImage: PKUIMediaData {}
extension URL: PKUIMediaData {}
extension Data: PKUIMediaData {}
extension String: PKUIMediaData {}
extension PHAsset: PKUIMediaData {}


public protocol PKUIMedia {
    
    /// 指定使用的Page类
    var pk_pageClass: PKUIMediaBrowserPage.Type { get }
    
    /// 数据源
    var pk_data: PKUIMediaData? { get }
    
    /// 缩略图
    var pk_thumbnail: PKUIMediaData? { get }
    
    /// 资源下载 自己实现
    /// - Parameters:
    ///   - url:
    ///   - complete:
    func pk_downloadImage(_ url: URL, complete: @escaping (UIImage?) -> Void)
}


extension PKUIMedia {
    
    func parseImageData(data: PKUIMediaData, complete: @escaping (UIImage?) -> Void) {
        switch data {
        case let image as UIImage:
            complete(image)
            
        case let url as URL:
            self.parseImageURL(url: url, complete: complete)
            
        case let str as String:
            guard let url = URL(string: str) else {
                complete(nil)
                return
            }
            self.parseImageURL(url: url, complete: complete)
            
        case let data as Data:
            complete(UIImage(data: data))
            
        case let asset as PHAsset:
            let options = PHImageRequestOptions()
            PHImageManager.default().requestImage(for: asset, targetSize: .zero, contentMode: .default, options: options) { image, _ in
                DispatchQueue.main.async {
                    complete(image)
                }
            }
            
        default:
            complete(nil)
            
        }
    }
    
    func parseImageURL(url: URL, complete: @escaping (UIImage?) -> Void) {
        if url.isFileURL {
            guard let data = try? Data.init(contentsOf: url) else {
                return
            }
            complete(UIImage.init(data: data))
            return
        }
        
        self.pk_downloadImage(url) { obj in
            complete(obj)
        }
    }
}
