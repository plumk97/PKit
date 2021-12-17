//
//  BubbleViewController.swift
//  PKit
//
//  Created by Plumk on 2020/4/2.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import PKit

class BubbleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonItemClick(_:event:)))
    }
    
    @objc func addBarButtonItemClick(_ sender: UIBarButtonItem, event: UIEvent) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .BR
        bubble.show(attach: event.allTouches?.first?.view)
    }
    
    func contentView() -> UIView {
        let label = UILabel()
        label.text = "BubbleViewController\nBubbleViewController\nBubbleViewController"
        label.numberOfLines = 0
        label.textColor = .darkText
        label.sizeToFit()
        
        return label
    }

    @IBAction func tLC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .TL
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func tC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .T
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func tRC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .TR
        bubble.show(attach: sender, in: self.view)
    }
    
    
    @IBAction func lTC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .LT
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func lC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .L
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func LBC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .LB
        bubble.show(attach: sender, in: self.view)
    }
 
    
    @IBAction func bLC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .BL
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func bC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .B
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func bRC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .BR
        bubble.show(attach: sender, in: self.view)
    }
    
    
    @IBAction func rTC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .RT
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func rC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .R
        bubble.show(attach: sender, in: self.view)
    }
    
    @IBAction func rBC(_ sender: UIButton) {
        let bubble = PKUIBubble.init(contentView: self.contentView())
        bubble.popupDirection = .RB
        bubble.show(attach: sender, in: self.view)
    }
}
