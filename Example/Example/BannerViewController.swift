//
//  BannerViewController.swift
//  PKit
//
//  Created by Plumk on 2020/12/23.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import PKit

class BannerViewController: UIViewController {

    struct Model {
        let url: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banner"
        
        let banner = PKUIBanner<Model>()
        banner.frame = .init(x: 15, y: 200, width: self.view.frame.width - 30, height: 200)
        banner.backgroundColor = .black
        banner.contentMode = .scaleAspectFill
        self.view.addSubview(banner)
        
        banner.imageDownloadCallback = { idx, model, complete in
            
            let session = URLSession.shared
            session.dataTask(with: URL.init(string: model.url)!) { (data, _, _) in
                DispatchQueue.main.async {
                    if let x = data {
                        complete(UIImage.init(data: x))
                    } else {
                        complete(nil)
                    }
                }
            }.resume()
            
        }
        
        banner.didClickCallback = { idx, model in
            print(model.url)
        }
        
        banner.models = [
            .init(url: "https://t7.baidu.com/it/u=1338072303,1599910722&fm=193&f=GIF"),
            .init(url: "https://t7.baidu.com/it/u=3832474391,1084278450&fm=193&f=GIF"),
            .init(url: "https://t7.baidu.com/it/u=1021886030,3979549266&fm=193&f=GIF"),
            .init(url: "https://t7.baidu.com/it/u=4158772482,569675020&fm=193&f=GIF")
        ]
        
        banner.playDuration = 2
        banner.autoplay = true
        
        
        let banner1 = PKUIBanner<Model>()
        banner1.frame = .init(x: 15, y: 450, width: self.view.frame.width - 30, height: 200)
        banner1.backgroundColor = .black
        banner1.contentMode = .scaleAspectFill
        self.view.addSubview(banner1)
        
        banner1.imageDownloadCallback = { idx, model, complete in
            
            let session = URLSession.shared
            session.dataTask(with: URL.init(string: model.url)!) { (data, _, _) in
                DispatchQueue.main.async {
                    if let x = data {
                        complete(UIImage.init(data: x))
                    } else {
                        complete(nil)
                    }
                }
            }.resume()
            
        }
        
        banner1.models = [
            .init(url: "https://t7.baidu.com/it/u=1338072303,1599910722&fm=193&f=GIF")
        ]
        
        banner1.playDuration = 2
        banner1.autoplay = true
    }

}
