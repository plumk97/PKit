//
//  BubbleViewController.swift
//  PLKit
//
//  Created by iOS on 2020/4/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class BubbleViewController: UIViewController {

    @IBAction func btnClick(_ sender: UIButton) {
        let label = UILabel()
        label.text = "BubbleViewController"
        label.textColor = .darkText
        label.sizeToFit()
        
        PLBubble.init(contentView: label).show(attach: sender)
    }
    
}
