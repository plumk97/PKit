//
//  AudioRecorderViewController.swift
//  PLKit
//
//  Created by Plumk on 2020/11/27.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import AVFoundation
class AudioRecorderViewController: UIViewController {

    let model: PLAudioRecorder.RecordModel = .init(format: .aac)
    
    var isWatching = false
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var rootTopConstraint: NSLayoutConstraint!
    
    var audioPlayer: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.delegate!.window!!
            self.rootTopConstraint.constant = window.safeAreaInsets.top + 44 + 10
        } else {
            self.rootTopConstraint.constant = 20 + 44 + 10
        }
        
        self.model.durationChangeCallback = {
            
            let m = $0 / 60
            let s = $0 % 60
            self.durationLabel.text = String(format: "%02d:%02d", m, s)
        }
        
        self.model.completeCallback = {
            print($0, $1)
        }
        print(self.model.path!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isWatching {
            isWatching = true
            self.model.addObserver(self, forKeyPath: "isRecording", options: .new, context: nil)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isWatching {
            isWatching = false
            self.model.removeObserver(self, forKeyPath: "isRecording")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "isRecording":
            DispatchQueue.main.async {
                self.recordBtn.setTitle(self.model.isRecording ? "停止" : "录制", for: .normal)
            }
        default:
            break
        }
        
    }
    
    @IBAction func recordBtnClick(_ sender: UIButton) {
        guard self.audioPlayer?.isPlaying ?? false == false else {
            return
        }
        
        if !self.model.isRecording {
            self.model.start()
        } else {
            self.model.stop()
        }
    }
    
    @IBAction func playBtnClick(_ sender: UIButton) {
        
        guard !self.model.isRecording else {
            return
        }
        
        if self.audioPlayer?.isPlaying ?? false {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            
            sender.setTitle("播放", for: .normal)
        } else {
            self.audioPlayer = try? AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: self.model.path))
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            
            sender.setTitle("停止", for: .normal)
        }
    }
}

extension AudioRecorderViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer = nil
        self.playBtn.setTitle("播放", for: .normal)
    }
}
