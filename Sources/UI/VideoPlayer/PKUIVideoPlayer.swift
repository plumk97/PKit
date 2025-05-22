//
//  PKUIVideoPlayer.swift
//  PKit
//
//  Created by 李铁柱 on 2023/12/12.
//

import UIKit
import AVFoundation

open class PKUIVideoPlayer: NSObject {
    
    public var volume: Float {
        set { self.player.volume = newValue }
        get { self.player.volume }
    }
    
    public var rate: Float {
        set { self.player.rate = newValue }
        get { self.player.rate }
    }
    
    public var currentTime: CMTime { self.player.currentTime() }
    public var duration: CMTime { self.player.currentItem?.duration ?? .zero }
    public var presentationSize: CGSize { self.player.currentItem?.presentationSize ?? .zero }
    
    ///
    public weak var delegate: PKUIVideoPlayerDelegate?
    
    public private(set) var playState: PlayState = .stoped
    
    public private(set) var resource: Resource?
    
    ///
    public let renderView = PKUIVideoPlayerRenderView()
    
    
    private let player = AVPlayer()
    
    private var timeObserver: Any?
    
    
    public override init() {
        super.init()
        
        self.renderView.player = self.player
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) {[unowned self] time in
            self.timeChanged(time)
        }
    }
    
    deinit {
        if let currentItem = self.player.currentItem {
            self.removeItemObserver(currentItem)
        }
        if let timeObserver {
            self.player.removeTimeObserver(timeObserver)
        }
    }
    
    open func setResource(_ resource: Resource?) {
        self.stop()
        self.resource = resource
        self.reloadResource()
    }
    
    open func play() {
        guard self.player.status == .readyToPlay else {
            self.playState = .willPlay
            return
        }
        
        self.playState = .playing
        self.player.play()
    }
    
    open func pause() {
        guard self.playState == .playing else {
            return
        }
        
        self.playState = .paused
        self.player.pause()
    }
    
    open func stop() {
        guard self.playState != .stoped else {
            return
        }
        
        self.player.pause()
        self.playState = .stoped
        self.resource = nil
        self.reloadResource()
    }
    
    open func seek(_ time: CMTime, toleranceBefore: CMTime = .init(value: 1, timescale: 10), toleranceAfter: CMTime = .init(value: 1, timescale: 10)) {
        self.player.seek(to: .zero, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }
    
    func timeChanged(_ time: CMTime) {
        guard let currentItem = self.player.currentItem else {
            return
        }
        
        self.delegate?.videoPlayer(self, didChangedPlayTime: time)
        if time.seconds >= currentItem.duration.seconds {
            self.playState = .played
            self.delegate?.videoPlayerDidFinishPlaying(self)
        }
    }
    
    func reloadResource() {
        let item: AVPlayerItem?
        if let resource = self.resource {
            switch resource {
            case let .url(url):
                item = AVPlayerItem(url: url)
            case let .asset(asset):
                item = AVPlayerItem(asset: asset)
            }
        } else {
            item = nil
        }
        
        if let currentItem = self.player.currentItem {
            currentItem.cancelPendingSeeks()
            self.removeItemObserver(currentItem)
        }
        
        self.player.replaceCurrentItem(with: item)
        
        if let item = item {
            self.delegate?.videoPlayerStartLoading(self)
            self.addItemObserver(item)
        }
    }
    
    // MARK: - KVO
    func addItemObserver(_ item: AVPlayerItem) {
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    func removeItemObserver(_ item: AVPlayerItem) {
        item.removeObserver(self, forKeyPath: "status")
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }
        
        if let item = object as? AVPlayerItem {
            switch keyPath {
            case "status":
                switch item.status {
                case .unknown:
                    break
                    
                case .readyToPlay:
                    if self.playState == .willPlay {
                        self.play()
                    }
                    self.delegate?.videoPlayerReadToPlay(self)
                    
                case .failed:
                    self.stop()
                    self.delegate?.videoPlayer(self, loadFailed: item.error)
                    
                @unknown default:
                    break
                }
                
            default:
                break
            }
        }
        
    }
}


// MARK: - Resource
extension PKUIVideoPlayer {
    public enum Resource {
        case url(URL)
        case asset(AVAsset)
    }
}

// MARK: - Status
extension PKUIVideoPlayer {
    public enum PlayState {
        case stoped
        case paused
        case willPlay
        case playing
        case played
    }
}
