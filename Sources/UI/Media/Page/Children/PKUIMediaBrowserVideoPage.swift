//
//  PKUIMediaBrowserVideoPage.swift
//  PKit
//
//  Created by 李铁柱 on 2023/12/12.
//

import UIKit
import Photos

open class PKUIMediaBrowserVideoPage: PKUIMediaBrowserPage {

    let player = PKUIVideoPlayer()

    open override var transitioningView: UIView? {
        self.player.renderView
    }
    
    private let containerView = UIView()
    
    open override func commInit() {
        super.commInit()
        
        self.player.renderView.videoGravity = .resize
        self.player.delegate = self
        
        self.containerView.addSubview(self.player.renderView)
        self.addSubview(self.containerView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard !self.player.presentationSize.equalTo(.zero) else {
            return
        }
        
        self.containerView.frame = self.bounds
        
        var frame: CGRect = .init(origin: .zero, size: self.player.presentationSize.fitSize(targetSize: self.bounds.size))
        frame.origin.x = (self.bounds.width - frame.width) / 2
        frame.origin.y = (self.bounds.height - frame.height) / 2
        self.player.renderView.frame = frame
        
    }
    
    open override func setMedia(_ media: PKUIMedia) {
        super.setMedia(media)
        
        switch media.pk_data {
        case let str as String:
            if let url = URL(string: str) {
                self.player.setResource(.url(url))
            }
        
        case let url as URL:
            self.player.setResource(.url(url))
            
        case let asset as PHAsset:
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) {[weak self] (asset, _, _) in
                guard let asset = asset as? AVURLAsset else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.player.setResource(.asset(asset))
                }
            }
            
        default:
            break
        }
    }
    
    open override func didEnter() {
        self.player.play()
    }
    
    open override func didLeave() {
        self.player.pause()
    }
    
    open override func tapCloseGestureHandle(_ sender: UITapGestureRecognizer) {
        if self.player.playState == .playing {
            self.player.pause()
        } else if self.player.playState == .paused {
            self.player.play()
        }
    }
    
    open override func closePanProgressUpdate(progress: CGFloat, beginPoint: CGPoint, offset: CGPoint) {
        let scale = min(1, max(0.6, 1 - progress))
        self.player.renderView.transform = CGAffineTransform.identity
            .translatedBy(x: offset.x - beginPoint.x, y: offset.y - beginPoint.y)
            .scaledBy(x: scale, y: scale)
    }

    open override func closePanRestore() {
        UIView.animate(withDuration: 0.25) {
            self.player.renderView.transform = .identity
        }
    }
    
}

// MARK: - PKUIVideoPlayerDelegate
extension PKUIMediaBrowserVideoPage: PKUIVideoPlayerDelegate {
    
    public func videoPlayerDidFinishPlaying(_ player: PKUIVideoPlayer) {
        self.player.seek(.zero)
        self.player.play()
    }
    
    public func videoPlayerReadToPlay(_ player: PKUIVideoPlayer) {
        self.setNeedsLayout()
    }
}
