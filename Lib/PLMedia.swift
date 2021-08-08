//
//  PLMedia.swift
//  PLKit
//
//  Created by mini2019 on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import Photos

protocol PLMediaData {}

extension UIImage: PLMediaData {}
extension URL: PLMediaData {}
extension Data: PLMediaData {}
extension String: PLMediaData {}
extension PHAsset: PLMediaData {}


protocol PLMedia {
    
    /// 指定使用的Page类
    var pl_pageClass: PLMediaBrowserPage.Type { get }
    
    /// 数据源
    var pl_data: PLMediaData? { get }
    
    /// 缩略图
    var pl_thumbnail: PLMediaData? { get }
    
    /// 资源下载 自己实现
    /// - Parameters:
    ///   - url:
    ///   - complete:
    func pl_mediaDownload(_ url: URL, complete: @escaping (Any?)->Void)
}
