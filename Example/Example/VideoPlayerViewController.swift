//
//  VideoPlayerViewController.swift
//  Example
//
//  Created by 李铁柱 on 2023/12/12.
//  Copyright © 2023 Plumk. All rights reserved.
//

import UIKit
import PKit
import AVFoundation

let urls: [URL] = [
    URL(string: "https://vd2.bdstatic.com/mda-kj9yrgneyh6n01xy/sc/mda-kj9yrgneyh6n01xy.mp4")!,
    URL(fileURLWithPath: "/Users/litiezhu/Downloads/2023-12-12 19.40.29.mp4")
]

class VideoPlayerViewController: UIViewController {

    let player = PKUIVideoPlayer()
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pk.navigationConfig?.isTranslucent = false
        
        self.player.setResource(.url(urls[0]))
        
        self.player.volume = 0
        self.player.delegate = self
        self.player.renderView.videoGravity = .resizeAspect
        self.view.addSubview(self.player.renderView)
        self.player.renderView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        self.player.play()
    }
    
    @IBAction func playBtnClick(_ sender: UIButton) {
        self.player.play()
    }
    
    @IBAction func pauseBtnClick(_ sender: UIButton) {
        self.player.pause()
    }
    
    @IBAction func stopBtnClick(_ sender: UIButton) {
        self.player.stop()
    }
    
    @IBAction func toggleBtnClick(_ sender: UIButton) {
        self.index += 1
        self.player.setResource(.url(urls[index % urls.count]))
    }
}


// MARK: - PKUIVideoPlayerDelegate
extension VideoPlayerViewController: PKUIVideoPlayerDelegate {
    func videoPlayerDidFinishPlaying(_ player: PKUIVideoPlayer) {
        player.seek(.zero)
    }
    
    func videoPlayer(_ player: PKUIVideoPlayer, didChangedPlayTime time: CMTime) {
        print(time.seconds)
    }
    
    func videoPlayerReadToPlay(_ player: PKUIVideoPlayer) {
        print("videoPlayerReadToPlay")
        print(player.presentationSize)
    }
    
    func videoPlayer(_ player: PKUIVideoPlayer, loadFailed error: Error?) {
        print("videoPlayer:loadFailed:")
    }
}
