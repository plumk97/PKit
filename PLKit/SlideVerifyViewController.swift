//
//  SlideVerifyViewController.swift
//  PLKit
//
//  Created by iOS on 2019/7/3.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class SlideVerifyViewController: UIViewController {

    @IBAction func btnClick(_ sender: Any) {
        
        let verify = PLSlideVerify()
        verify.config = .init(data: "http://e.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3cef70d70409845d688d53f20f7.jpg")
        verify.show {
            print("验证成功")
        }
    }
}
