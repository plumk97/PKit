//
//  PKUIMediaBrowserDelegate.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import UIKit


public protocol PKUIMediaBrowserDelegate: AnyObject {
    func mediaBrowserNumberOfMedia(_ mediaBrowser: PKUIMediaBrowser) -> Int
    func mediaBrowser(_ mediaBrowser: PKUIMediaBrowser, mediaAt index: Int) -> PKUIMedia
    
    func mediaBrowserPresentFromView(_ mediaBrowser: PKUIMediaBrowser) -> (view: UIView, image: UIImage)?
    func mediaBrowserDismissToView(_ mediaBrowser: PKUIMediaBrowser) -> UIView?
}


public extension PKUIMediaBrowserDelegate {
    func mediaBrowserPresentFromView(_ mediaBrowser: PKUIMediaBrowser) -> (view: UIView, image: UIImage)? {
        return nil
    }
    
    func mediaBrowserDismissToView(_ mediaBrowser: PKUIMediaBrowser) -> UIView? {
        return nil
    }
}
