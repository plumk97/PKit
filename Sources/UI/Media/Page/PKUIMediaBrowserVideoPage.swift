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
    public let playerView = PlayerView()
    
    ///
    public let loadingIndicator = UIActivityIndicatorView(style: .white)
    
    /// 当前是否显示中
    public var isDisplaying: Bool = false
    
    /// 当前是否已经准备播放
    public var isReadyToPlay: Bool = false
    
    open override func commInit() {
        super.commInit()
        
    
        /// 防止触发layout
        let wrapView = UIView()
        wrapView.addSubview(self.playerView)
        self.addSubview(wrapView)
        
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.loadingIndicator)
        self.loadingIndicator.startAnimating()
        
        self.addConstraints([
            .init(item: self.loadingIndicator, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -10),
            .init(item: self.loadingIndicator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 10)
        ])
        
        self.parsePlayerItem {[weak self] item in
            self?.playerView.setPlayerItem(item)
        }
        
        self.playerView.loadComplete = {[unowned self] in
            self.isReadyToPlay = true
            self.loadingIndicator.stopAnimating()
            if self.isDisplaying {
                self.playerView.player.play()
            }
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
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, _, _) in
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
    
    open override func tapCloseGestureHandle(_ sender: UITapGestureRecognizer) {
        if self.isReadyToPlay {
            if self.playerView.player.rate >= 1.0 {
                self.playerView.player.pause()
            } else {
                self.playerView.player.play()
            }
        }
    }
    
    open override func didEnter() {
        self.isDisplaying = true
        if self.isReadyToPlay {
            self.playerView.player.play()
        }
    }
    
    open override func didLeave() {
        self.isDisplaying = false
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
        
        
        /// 加载完成可以开始播放
        public var loadComplete: (() -> Void)?
        
        /// 当前播放item
        public private(set) var playerItem: AVPlayerItem?
        
        /// 播放器
        public let player = AVPlayer()
        
        /// 预览界面
        public let previewImageView = UIImageView()
        
        /// 时间观察者
        public var timeObserver: Any?
        
        open override class var layerClass: AnyClass { AVPlayerLayer.self }

        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            if let layer = self.layer as? AVPlayerLayer {
                
                layer.videoGravity = .resizeAspect
                layer.player = self.player
            }
            self.player.pause()
            
            self.previewImageView.contentMode = .scaleAspectFill
            self.previewImageView.clipsToBounds = true
            self.addSubview(self.previewImageView)
            
            self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) {[unowned self] time in
                guard let currentItem = self.player.currentItem else {
                    return
                }
                
                if time.seconds >= currentItem.duration.seconds {
                    self.player.seek(to: .zero) { _ in
                        self.player.play()
                    }
                }
            }
        }
        
        deinit {
            if let timeObserver = self.timeObserver {
                self.player.removeTimeObserver(timeObserver)
            }
            self.playerItem?.removeObserver(self, forKeyPath: "status")
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            self.previewImageView.frame = self.bounds
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open func setPlayerItem(_ item: AVPlayerItem?) {
            self.playerItem?.removeObserver(self, forKeyPath: "status")
            
            self.playerItem = item
            self.player.replaceCurrentItem(with: item)
            
            item?.addObserver(self, forKeyPath: "status", context: nil)
        }
        
        open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
            guard let status = self.playerItem?.status else {
                return
            }
            
            switch status {
            case .readyToPlay:
                self.loadComplete?()
                
            default:
                break
            }
            
        }
    }
}
