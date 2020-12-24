//
//  PLBanner.swift
//  PLKit
//
//  Created by Plumk on 2020/12/23.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class PLBanner<Model>: UIView {
    
    /// 图片下载完成回调
    typealias ImageDownlaodCompleteCallback = (UIImage?) -> Void
    
    /// 图片下载回调 外部自己处理下载以及缓存逻辑
    typealias ImageDownloadCallback = (Int, Model, @escaping ImageDownlaodCompleteCallback) -> Void
    
    typealias DidClickCallback = (Int, Model) -> Void
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    /// 图片下载回调 外部自己处理下载以及缓存逻辑
    var imageDownloadCallback: ImageDownloadCallback?
    
    /// 点击回调
    var didClickCallback: DidClickCallback?
    
    ///
    var models = [Model]() {
        didSet {
            self.predownloadBothSideImage()
            self.pageControl.numberOfPages = self.models.count
            self.collectionView.reloadData()
            self.reloadAutoplayTimer()
            self.setNeedsLayout()
        }
    }
    
    /// 当前第几页
    fileprivate(set) var page: Int = 0
    
    
    /// 是否自动滚动
    var autoplay = false {
        didSet {
            self.reloadAutoplayTimer()
        }
    }
    
    /// 滚动间隔
    var playDuration: TimeInterval = 0 {
        didSet {
            self.reloadAutoplayTimer()
        }
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            self.leftOverstepImageView.contentMode = self.contentMode
            self.rightOverstepImageView.contentMode = self.contentMode
            self.collectionView.reloadData()
        }
    }

    private var collectionViewLayout: UICollectionViewFlowLayout!
    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    
    private var delegateRepeater: DelegateRepeater!
    
    private var leftOverstepImageView: UIImageView!
    private var rightOverstepImageView: UIImageView!
    
    private var autoplayTimer: Timer?
    
    private func commInit() {
        self.clipsToBounds = true
        self.delegateRepeater = DelegateRepeater(banner: self)
        
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionViewLayout.scrollDirection = .horizontal
        self.collectionViewLayout.minimumLineSpacing = 0
        self.collectionViewLayout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.isPagingEnabled = true
        self.collectionView.bounces = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.delegate = self.delegateRepeater
        self.collectionView.dataSource = self.delegateRepeater
        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: "cell")
        self.addSubview(self.collectionView)
        
        self.leftOverstepImageView = UIImageView()
        self.leftOverstepImageView.clipsToBounds = true
        self.collectionView.addSubview(self.leftOverstepImageView)
        
        self.rightOverstepImageView = UIImageView()
        self.rightOverstepImageView.clipsToBounds = true
        self.collectionView.addSubview(self.rightOverstepImageView)
        
        self.pageControl = UIPageControl()
        self.addSubview(self.pageControl)
        
        self.collectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    deinit {
        self.collectionView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            self.rightOverstepImageView.frame.origin = .init(x: self.collectionView.contentSize.width, y: 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.collectionView.frame.equalTo(self.bounds) {
            self.collectionView.frame = self.bounds
            self.collectionViewLayout.itemSize = .init(width: self.bounds.width, height: self.bounds.height)
        }
        
        if self.models.count > 1 {
            self.collectionView.contentInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: self.bounds.width)
        } else {
            self.collectionView.contentInset = .zero
        }
        
        self.leftOverstepImageView.frame = .init(x: -self.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.rightOverstepImageView.frame = .init(x: self.collectionView.contentSize.width, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        self.pageControl.sizeToFit()
        self.pageControl.frame.origin = .init(x: (self.bounds.width - self.pageControl.bounds.width) / 2,
                                              y: self.bounds.height - self.pageControl.bounds.height - 10)
    }
    
    func setPage(_ page: Int, animated: Bool) {
        guard page >= 0 && page < self.models.count else {
            return
        }
        self.page = page
        self.collectionView.setContentOffset(.init(x: CGFloat(page) * self.collectionView.frame.width, y: 0), animated: animated)
        self.updatePage()
    }

    fileprivate func updatePage() {
        self.pageControl.currentPage = self.page
    }
    
    fileprivate func predownloadBothSideImage() {
        guard self.models.count > 1 else {
            return
        }
        
        self.imageDownloadCallback?(0, self.models[0], {[weak self] in
            self?.rightOverstepImageView.image = $0
        })
        
        self.imageDownloadCallback?(self.models.count - 1, self.models.last!, {[weak self] in
            self?.leftOverstepImageView.image = $0
        })
    }
    
    fileprivate func reloadAutoplayTimer() {
        
        let isEnableTimer = self.superview != nil && self.autoplay && self.playDuration > 0 && self.models.count > 1
        
        if isEnableTimer {
            if self.autoplayTimer == nil {
                self.autoplayTimer = Timer.init(timeInterval: self.playDuration, target: self, selector: #selector(autoplayTimerTick), userInfo: nil, repeats: true)
                RunLoop.main.add(self.autoplayTimer!, forMode: .common)
            }
        } else {
            self.autoplayTimer?.invalidate()
            self.autoplayTimer = nil
        }
    }
    
    @objc fileprivate func autoplayTimerTick() {
        guard self.models.count > 1 else {
            self.reloadAutoplayTimer()
            return
        }
        
        var page = self.page + 1
        if page >= self.models.count {
            page = 0
        }
        self.setPage(page, animated: true)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.reloadAutoplayTimer()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension PLBanner {
    class DelegateRepeater: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
        
        weak var banner: PLBanner!
        init(banner: PLBanner) {
            super.init()
            self.banner = banner
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.banner.models.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
            cell.imageView.contentMode = self.banner.contentMode
            
            if indexPath.row == self.banner.models.count - 1 {
                cell.imageView.image = self.banner.leftOverstepImageView.image
            } else if indexPath.row == 0 {
                cell.imageView.image = self.banner.rightOverstepImageView.image
            }
            
            let model = self.banner.models[indexPath.row]
            self.banner.imageDownloadCallback?(indexPath.row, model, {[weak cell, weak self] image in
                guard let _banenr = self?.banner else {
                    return
                }
                cell?.imageView.image = image
                
                if indexPath.row == 0 {
                    _banenr.rightOverstepImageView.image = image
                } else if indexPath.row == _banenr.models.count - 1 {
                    _banenr.leftOverstepImageView.image = image
                }
            })
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let model = self.banner.models[indexPath.row]
            self.banner.didClickCallback?(indexPath.row, model)
        }
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            guard page >= 0 && page < self.banner.models.count else {
                return
            }
            self.banner.page = page
            self.banner.updatePage()
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.x <= -scrollView.bounds.width {
                scrollView.setContentOffset(.init(x: scrollView.contentSize.width - scrollView.bounds.width, y: 0), animated: false)
            } else if scrollView.contentOffset.x >= scrollView.contentSize.width {
                scrollView.setContentOffset(.init(x: 0, y: 0), animated: false)
            }
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.x <= -scrollView.bounds.width {
                scrollView.setContentOffset(.init(x: scrollView.contentSize.width - scrollView.bounds.width, y: 0), animated: false)
            } else if scrollView.contentOffset.x >= scrollView.contentSize.width {
                scrollView.setContentOffset(.init(x: 0, y: 0), animated: false)
            }
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.banner.autoplayTimer?.invalidate()
            self.banner.autoplayTimer = nil
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            self.banner.reloadAutoplayTimer()
        }
    }
}


// MARK: - PLBanner Cell
extension PLBanner {
    fileprivate class Cell: UICollectionViewCell {
        
        var imageView: UIImageView!
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.commInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.commInit()
        }
        
        func commInit() {
            self.imageView = UIImageView()
            self.imageView.clipsToBounds = true
            self.contentView.addSubview(self.imageView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.imageView.frame = self.contentView.bounds
        }
    }
}
