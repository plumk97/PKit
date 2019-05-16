//
//  PhotoBrowserViewController.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func btnClick(_ sender: Any) {
        
        let urls = [
            "https://www.baidu.com/img/bd_logo1.png",
            "http://b.hiphotos.baidu.com/image/h%3D300/sign=77d1cd475d43fbf2da2ca023807fca1e/9825bc315c6034a8ef5250cec5134954082376c9.jpg",
        "http://e.hiphotos.baidu.com/image/h%3D300/sign=0734f78af2039245beb5e70fb795a4a8/b8014a90f603738d6d8d0d65bd1bb051f919ecb6.jpg",
        "http://b.hiphotos.baidu.com/image/h%3D300/sign=ad628627aacc7cd9e52d32d909032104/32fa828ba61ea8d3fcd2e9ce9e0a304e241f5803.jpg",
        "http://e.hiphotos.baidu.com/image/h%3D300/sign=a9e671b9a551f3dedcb2bf64a4eff0ec/4610b912c8fcc3cef70d70409845d688d53f20f7.jpg"]
        let browser = PLPhotoBrowser(photos: urls)
        self.present(browser, animated: true, completion: nil)
    }
}
