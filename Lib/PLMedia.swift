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

class PLMedia {
    typealias ImageDownloadCallback = (URL, @escaping (UIImage?)->Void) -> Void
    
    enum MediaType {
        case image
        case video
    }
    
    private(set) var data: PLMediaData?
    private(set) var thumbnail: PLMediaData?
    private(set) var mediaType: MediaType!
    
    private(set) var imageDownloadCallback: ImageDownloadCallback?
    
    init(data: PLMediaData?, thumbnail: PLMediaData?, mediaType: MediaType = .image) {
        self.data = data
        self.thumbnail = thumbnail
        
        if let x = data as? PHAsset {
            self.mediaType = x.mediaType == .image ? .image : .video
        } else {
            self.mediaType = mediaType
        }
    }
    
    func setImageDownloadCallback(_ callback: ImageDownloadCallback?) {
        self.imageDownloadCallback = callback
    }
}
