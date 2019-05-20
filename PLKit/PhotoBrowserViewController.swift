//
//  PhotoBrowserViewController.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {

    var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView.init(frame: .init(x: 20, y: 100, width: 300, height: 199))
        self.view.addSubview(self.imageView)
        
        self.loadImage(url: "https://ss1.baidu.com/9vo3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=92afee66fd36afc3110c39658318eb85/908fa0ec08fa513db777cf78376d55fbb3fbd9b3.jpg")
    }
    
    func loadImage(url: String) {
        let data = try? Data.init(contentsOf: URL.init(string: url)!)
        if data != nil {
            let image = UIImage.init(data: data!)
            imageView.image = image
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let plainText = try! String.init(contentsOfFile: Bundle.main.path(forResource: "imagesrc", ofType: "text")!)
        
        let urls = plainText.components(separatedBy: "\n") as [PLPhotoDatasource]
        let photos = urls.map({ (el) -> PLPhoto in
            let photo = PLPhoto.init(data: el, thumbnail: nil)
            return photo
        })
        
        let browser = PLPhotoBrowser(photos: photos, initIndex: 8, fromView: self.imageView, fromOriginSize: self.imageView.image?.size ?? .zero)
        browser.didChangePageCallback = { _, index in
            self.loadImage(url: urls[index] as! String)
            print(index)
        }
        self.present(browser, animated: true, completion: nil)
    }
}
