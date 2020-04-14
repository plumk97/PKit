//
//  BubbleViewController.swift
//  PLKit
//
//  Created by iOS on 2020/4/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class BubbleViewController: UIViewController {

    func contentView() -> UIView {
        let label = UILabel()
        label.text = "BubbleViewController\nBubbleViewController\nBubbleViewController"
        label.numberOfLines = 0
        label.textColor = .darkText
        label.sizeToFit()
        
        return label
    }

    @IBAction func tLC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .TL
        bubble.show(attach: sender)
    }
    
    @IBAction func tC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .T
        bubble.show(attach: sender)
    }
    
    @IBAction func tRC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .TR
        bubble.show(attach: sender)
    }
    
    
    @IBAction func lTC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .LT
        bubble.show(attach: sender)
    }
    
    @IBAction func lC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .L
        bubble.show(attach: sender)
    }
    
    @IBAction func LBC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .LB
        bubble.show(attach: sender)
    }
 
    
    @IBAction func bLC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .BL
        bubble.show(attach: sender)
    }
    
    @IBAction func bC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .B
        bubble.show(attach: sender)
    }
    
    @IBAction func bRC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .BR
        bubble.show(attach: sender)
    }
    
    
    @IBAction func rTC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .RT
        bubble.show(attach: sender)
    }
    
    @IBAction func rC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .R
        bubble.show(attach: sender)
    }
    
    @IBAction func rBC(_ sender: UIButton) {
        let bubble = PLBubble.init(contentView: self.contentView())
        bubble.popupDirection = .RB
        bubble.show(attach: sender)
    }
}
