//
//  PhotoBrowserViewController.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: UIViewController {

    class BUTT: UIButton {
        deinit {
            print("BUTT")
        }
    }
    var imageView: UIImageView!
    var imageCache = NSCache<NSString, UIImage>()
    var index = 8
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PhotoBrowserViewController"
        
        self.navigationItem.rightBarButtonItems = [
            .init(title: "item", style: .plain, target: nil, action: nil),
            .init(title: "item", style: .plain, target: nil, action: nil),
            .init(customView: BUTT())]
        
        imageView = UIImageView.init(frame: .init(x: 20, y: 100, width: 300, height: 199))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.view.addSubview(self.imageView)
        
        self.loadImage(url: "https://ss1.baidu.com/9vo3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=92afee66fd36afc3110c39658318eb85/908fa0ec08fa513db777cf78376d55fbb3fbd9b3.jpg")
    }
    
    func loadImage(url: String) {
        
        let key = url as NSString
        if let image = self.imageCache.object(forKey: key) {
            imageView.image = image
            return
        }
        
        guard let uurl = URL.init(string: url) else {
            return
        }
        
        URLSession.shared.downloadTask(with: uurl, completionHandler: {[weak self] (fileurl, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard fileurl != nil else {
                return
            }
            
            guard let data = try? Data.init(contentsOf: fileurl!) else {
                return
            }
            
            guard let image = UIImage.init(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.imageCache.setObject(image, forKey: key)
            }
            
        }).resume()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let plainText = try! String.init(contentsOfFile: Bundle.main.path(forResource: "imagesrc", ofType: "text")!)
        
        let urls = plainText.components(separatedBy: "\n") as [PLPhotoDatasource]
        let photos = urls.map({ (el) -> PLPhoto in
            let photo = PLPhoto.init(data: el, thumbnail: nil)
            return photo
        })
        
        let browser = PLPhotoBrowser(photos: photos, initIndex: self.index, fromView: self.imageView)
        browser.didChangePageCallback = { _, index in
            self.loadImage(url: urls[index] as! String)
            self.index = index
        }
        self.present(browser, animated: true, completion: nil)
    }
}
