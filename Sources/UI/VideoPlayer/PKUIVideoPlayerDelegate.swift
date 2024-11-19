//
//  PKUIVideoPlayerDelegate.swift
//  PKit
//
//  Created by 李铁柱 on 2023/12/12.
//

import Foundation
import AVFoundation

public protocol PKUIVideoPlayerDelegate: AnyObject {
    
    func videoPlayerDidFinishPlaying(_ player: PKUIVideoPlayer)
    func videoPlayer(_ player: PKUIVideoPlayer, didChangedPlayTime time: CMTime)
    
    func videoPlayerStartLoading(_ player: PKUIVideoPlayer)
    func videoPlayerReadToPlay(_ player: PKUIVideoPlayer)
    func videoPlayer(_ player: PKUIVideoPlayer, loadFailed error: Error?)
}

public extension PKUIVideoPlayerDelegate {
    func videoPlayerDidFinishPlaying(_ player: PKUIVideoPlayer) { 
        
    }
    
    func videoPlayer(_ player: PKUIVideoPlayer, didChangedPlayTime time: CMTime) {
        
    }
    
    func videoPlayerStartLoading(_ player: PKUIVideoPlayer) {
        
    }
    
    func videoPlayerReadToPlay(_ player: PKUIVideoPlayer) {
        
    }
    
    func videoPlayer(_ player: PKUIVideoPlayer, loadFailed error: Error?) {
        
    }
}
