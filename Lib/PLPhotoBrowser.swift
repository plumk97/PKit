//
//  PLPhotoBrowser.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

protocol PLPhotoProtocol {}
extension UIImage: PLPhotoProtocol {}
extension URL: PLPhotoProtocol {}
extension Data: PLPhotoProtocol {}
extension String: PLPhotoProtocol {}

/// 下载完成Callback
typealias PLPhotoBrowserDownloadCompletionCallback = (UIImage?)->Void

/// 下载Callback
typealias PLPhotoBrowserDownloadCallback = (URL, @escaping PLPhotoBrowserDownloadCompletionCallback)->Void

class PLPhotoBrowser: UIViewController {
    
    convenience init(photos: [PLPhotoProtocol], initIndex: Int = 0, fromView: UIView? = nil) {
        self.init()
        
        self.photos = photos
    }
    
    private(set) var photos: [PLPhotoProtocol]?

    fileprivate var downloadCallback: PLPhotoBrowserDownloadCallback?
    
    fileprivate var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var bounds = self.view.bounds
        bounds.size.width += 10
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.itemSize = bounds.size
        collectionLayout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView.init(frame: bounds, collectionViewLayout: collectionLayout)
        self.collectionView.backgroundColor = .black
        self.collectionView.isPagingEnabled = true
        self.collectionView.dataSource = self
        self.collectionView.register(PLPhotoBrowserCell.self, forCellWithReuseIdentifier: "PLPhotoBrowserCell")
        self.view.addSubview(self.collectionView)
        
        
        // 默认下载图片 无缓存
        self.setDownloadImageCallback { (url, completion) in
            
            URLSession.shared.downloadTask(with: url, completionHandler: { (fileurl, response, error) in
                
                var image: UIImage?
                defer {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
                
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
                
                image = UIImage.init(data: data)
                
            }).resume()
        }
    }
    
    /// 设置下载图片方法
    ///
    /// - Parameter callback:
    func setDownloadImageCallback(_ callback: @escaping PLPhotoBrowserDownloadCallback) {
        self.downloadCallback = callback
    }
}


fileprivate class PLPhotoBrowserCell: UICollectionViewCell {
    
    weak var browser: PLPhotoBrowser?
    
    var waitIndicator: UIActivityIndicatorView!
    var scrollView: PLPhotoBrowserScrollView!
    
    var photo: PLPhotoProtocol? {
        didSet {
            self.updatePhoto()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView = PLPhotoBrowserScrollView()
        self.contentView.addSubview(self.scrollView)
        
        self.waitIndicator = UIActivityIndicatorView.init(style: .white)
        self.contentView.addSubview(self.waitIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var bounds = self.contentView.bounds
        bounds.size.width -= 10
        self.scrollView.frame = bounds
        self.waitIndicator.center = .init(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    func updatePhoto() {
        
        if let str = self.photo as? String, let url = URL.init(string: str) {
            self.download(url: url)
        }
    }
    
    func download(url: URL) {
        self.waitIndicator.startAnimating()
        self.browser?.downloadCallback?(url, {[weak self] image in
            self?.waitIndicator.stopAnimating()
            self?.scrollView.image = image
        })
    }
}


// MARK: - UICollectionViewDataSource
extension PLPhotoBrowser: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PLPhotoBrowserCell", for: indexPath) as! PLPhotoBrowserCell
        cell.browser = self
        cell.photo = self.photos?[indexPath.row]
        return cell
    }
}
