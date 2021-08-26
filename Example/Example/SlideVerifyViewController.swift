//
//  SlideVerifyViewController.swift
//  PKit
//
//  Created by Plumk on 2019/7/3.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class SlideVerifyViewController: UIViewController {

    @IBAction func btnClick(_ sender: Any) {
        
        let verify = PLSlideVerify()
        verify.config = .init(data: "http://e.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3cef70d70409845d688d53f20f7.jpg")
        verify.show {
            print("验证成功")
        }
    }
}
