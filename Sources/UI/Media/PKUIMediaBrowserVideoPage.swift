//
//  PKUIMediaBrowserVideoPage.swift
//  PKit
//
//  Created by Plumk on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

open class PKUIMediaBrowserVideoPage: PKUIMediaBrowserImagePage {
    
    open var player: AVPlayer!
    open var playerLayer: AVPlayerLayer!
    open var isReadyToPlay = false
    
    open var playBtn: UIButton!
    open var timeObserver: Any?
    
    open override func commInit() {
        super.commInit()
        
        self.doubleTapGesture.isEnabled = false
        self.singleTapGesture.isEnabled = false
        self.scrollView.maximumZoomScale = 1
        
        self.player = AVPlayer()
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 2), queue: nil) {[weak self] (time) in
            guard let unself = self else {
                return
            }
            guard let duration = unself.player.currentItem?.duration.seconds,
                  let currentTime = unself.player.currentItem?.currentTime().seconds else {
                return
            }
            
            
            if currentTime >= duration {
                unself.playBtn.isHidden = false
                unself.singleTapGesture.isEnabled = false
            }
        }
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.contentView.layer.addSublayer(self.playerLayer)
        
        self.playBtn = UIButton(type: .custom)
        self.playBtn.setBackgroundImage(UIImage.init(named: "icon_play1"), for: .normal)
        self.playBtn.addTarget(self, action: #selector(playBtnClick(_:)), for: .touchUpInside)
        self.contentView.addSubview(self.playBtn)
        
        self.closeGesture.cancelsTouchesInView = false
        self.closeGesture.delaysTouchesEnded = false
        
    }
    
    deinit {
        if let x = self.timeObserver {
            self.player.removeTimeObserver(x)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.imageView.image == nil {
            self.contentView.frame = self.scrollView.bounds
        }
        
        self.playerLayer.frame = self.contentView.bounds
        
        self.playBtn.sizeToFit()
        self.playBtn.frame.origin = .init(x: (self.contentView.frame.width - self.playBtn.frame.width) / 2,
                                          y: (self.contentView.frame.height - self.playBtn.frame.height) / 2)
    }
    
    open override func loadResource() {
        super.loadResource()
        
        if let x = media.pl_thumbnail {
            self.showLoadingIndicator()
            self.parseData(data: x) {[weak self] image in
                self?.hideLoadingIndicator()
                self?.imageView.image = image
                self?.update()
            }
        }
        
        switch media.pl_data {
        case let x as String:
            guard let url = URL.init(string: x) else {
                return
            }
            
            let item = AVPlayerItem.init(url: url)
            self.replaceCurrentItem(item)
            
        case let x as URL:
            let item = AVPlayerItem.init(url: x)
            self.replaceCurrentItem(item)
            
        case let x as PHAsset:
            self.showLoadingIndicator()
            
            PHImageManager.default().requestAVAsset(forVideo: x, options: nil) {[weak self] (asset, _, _) in
                guard let asset = asset as? AVURLAsset else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.hideLoadingIndicator()
                    let item = AVPlayerItem.init(url: asset.url)
                    self?.replaceCurrentItem(item)
                }
            }
        default:
            break
        }
        
    }

    open func replaceCurrentItem(_ item: AVPlayerItem) {
        self.showLoadingIndicator()
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player.replaceCurrentItem(with: item)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "status":
            self.hideLoadingIndicator()
            if self.player.currentItem?.status == .readyToPlay {
                self.isReadyToPlay = true
            }
            self.player.currentItem?.removeObserver(self, forKeyPath: "status")
            
        default:
            break
        }
    }
    
    open override func singleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.player.rate != 0 {
                self.singleTapGesture.isEnabled = false
                
                self.player.pause()
                self.playBtn.isHidden = false
                self.imageView.isHidden = true
            }
        }
    }
    
    @objc open func playBtnClick(_ sender: UIButton) {
        guard self.isReadyToPlay else {
            return
        }
        
        self.playBtn.isHidden = true
        self.singleTapGesture.isEnabled = true
        
        if self.player.currentTime().seconds >= self.player.currentItem!.duration.seconds {
            self.player.seek(to: CMTime.init(value: 0, timescale: 1))
        }
        self.player.play()
    }
    
    // MARK: - UIScrollViewDelegate
    open override func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
