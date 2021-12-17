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
    var pl_pageClass: PKUIMediaBrowserPage.Type { get }
    
    /// 数据源
    var pl_data: PKUIMediaData? { get }
    
    /// 缩略图
    var pl_thumbnail: PKUIMediaData? { get }
    
    /// 资源下载 自己实现
    /// - Parameters:
    ///   - url:
    ///   - complete:
    func pl_mediaDownload(_ url: URL, complete: @escaping (Any?)->Void)
}
