//
//  PKUIMediaBrowserVideoPage.swift
//  PKit
//
//  Created by Plumk on 2023/8/16.
//

import UIKit
import AVFoundation
import Photos

open class PKUIMediaBrowserVideoPage: PKUIMediaBrowserPage {

    open override var transitioningView: UIView? {
        self.playerView
    }
    
    /// 播放器
    let playerView = PlayerView()
    
    open override func commInit() {
        super.commInit()
        
        let wrapView = UIView()
        wrapView.addSubview(self.playerView)
        self.addSubview(wrapView)
        
        self.parsePlayerItem {[weak self] item in
            self?.playerView.setPlayerItem(item)
        }
    }
    
    /// 解析data 为 playerItem
    /// - Parameter complete:
    open func parsePlayerItem(complete: @escaping (AVPlayerItem?) -> Void) {
        
        switch self.media.pk_data {
        case let str as String:
            guard let url = URL(string: str) else {
                complete(nil)
                return
            }
            complete(AVPlayerItem(url: url))
            
        case let url as URL:
            complete(AVPlayerItem(url: url))
            
        case let asset as PHAsset:
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) {[weak self] (asset, _, _) in
                guard let asset = asset as? AVURLAsset else {
                    DispatchQueue.main.async {
                        complete(nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    complete(AVPlayerItem(asset: asset))
                }
            }
            
        default:
            complete(nil)
        }
    }
    
    open override func didEnter() {
        self.playerView.player.play()
    }
    
    open override func didLeave() {
        self.playerView.player.pause()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard !self.isClosed else {
            return
        }
        
        self.playerView.superview?.frame = self.bounds
        self.playerView.frame = self.bounds
    }

    open override func closePanProgressUpdate(progress: CGFloat, beginPoint: CGPoint, offset: CGPoint) {
        let scale = min(1, max(0.6, 1 - progress))
        self.playerView.transform = CGAffineTransform.identity
            .translatedBy(x: offset.x - beginPoint.x, y: offset.y - beginPoint.y)
            .scaledBy(x: scale, y: scale)
    }

    open override func closePanRestore() {
        UIView.animate(withDuration: 0.25) {
            self.playerView.transform = .identity
        }
    }
    
    open override func dismissTransitioningAnimation() {
        self.playerView.alpha = 0
    }

}

// MARK: - PlayerView
extension PKUIMediaBrowserVideoPage {
    open class PlayerView: UIView {
        
        public private(set) var playerItem: AVPlayerItem?
        
        ///
        public let player = AVPlayer()
        
        /// 预览界面
        public let previewImageView = UIImageView()
        
        open override class var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            
            if let layer = self.layer as? AVPlayerLayer {
                
                layer.videoGravity = .resizeAspect
                layer.player = self.player
            }
            
            self.previewImageView.contentMode = .scaleAspectFill
            self.previewImageView.clipsToBounds = true
            self.addSubview(self.previewImageView)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            self.previewImageView.frame = self.bounds
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open func setPlayerItem(_ item: AVPlayerItem?) {
            self.playerItem = item
            self.player.replaceCurrentItem(with: item)
        }
    }
}
