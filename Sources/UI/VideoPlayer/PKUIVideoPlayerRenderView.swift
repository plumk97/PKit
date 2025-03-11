//
//  PKUIVideoPlayerRenderView.swift
//  PKit
//
//  Created by 李铁柱 on 2023/12/12.
//

import UIKit
import AVFoundation

open class PKUIVideoPlayerRenderView: UIView {

    public var videoGravity: AVLayerVideoGravity {
        set { self.playerLayer.videoGravity = newValue }
        get { self.playerLayer.videoGravity }
    }
    
    public var player: AVPlayer? {
        set { self.playerLayer.player = newValue }
        get { self.playerLayer.player }
    }
    
    private let playerLayer = AVPlayerLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    func commInit() {
        self.backgroundColor = .black
        self.layer.addSublayer(self.playerLayer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.playerLayer.frame = self.layer.bounds
        CATransaction.commit()
    }
    
}
