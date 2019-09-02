//
//  PLPhotoBrowser.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import YYImage

protocol PLPhotoDatasource {}
extension UIImage: PLPhotoDatasource {}
extension URL: PLPhotoDatasource {}
extension Data: PLPhotoDatasource {}
extension String: PLPhotoDatasource {}

class PLPhoto: NSObject {
    var thumbnail: PLPhotoDatasource?
    var data: PLPhotoDatasource?
    convenience init(data: PLPhotoDatasource?, thumbnail: PLPhotoDatasource?) {
        self.init()
        self.data = data
        self.thumbnail = thumbnail
    }
}

/// 下载完成Callback
typealias PLPhotoBrowserDownloadCompletionCallback = (UIImage?)->Void

/// 下载Callback
typealias PLPhotoBrowserDownloadCallback = (URL, Bool, @escaping PLPhotoBrowserDownloadCompletionCallback)->Void

/// 界面改变Callback
typealias PLPhotoBrowserDidChangePageCallback = (PLPhotoBrowser, Int)->Void

class PLPhotoBrowser: UIViewController {
    
    convenience init(photos: [PLPhoto], initIndex: Int = 0, fromView: UIImageView? = nil) {
        self.init()
        self.fromView = fromView
        self.photos = photos
        self.currentPageIndex = initIndex
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        // 默认下载图片 系统自带缓存
        self.setDownloadImageCallback { (url, isThumb, completion) in
            guard isThumb == false else {
                return
            }
            
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
                
                image = YYImage.init(data: data)
                
            }).resume()
        }
        
    }
    
    
    var itemSpacing: CGFloat = 10
    var enableSingleTapClose: Bool = true
    var didChangePageCallback: PLPhotoBrowserDidChangePageCallback?
    
    weak var fromView: UIImageView?
    
    private(set) var photos: [PLPhoto]? {
        didSet {
            self.updatePageTips()
        }
    }
    
    private(set) var currentPageIndex: Int = 0 {
        didSet {
            self.updatePageTips()
            if oldValue != currentPageIndex {
                self.didChangePageCallback?(self, currentPageIndex)
            }
        }
    }
    
    fileprivate var downloadCallback: PLPhotoBrowserDownloadCallback?
    fileprivate var collectionView: UICollectionView!
    fileprivate var pageTipsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        var bounds = self.view.bounds
        bounds.size.width += 10
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.itemSize = bounds.size
        collectionLayout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView.init(frame: bounds, collectionViewLayout: collectionLayout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.isPagingEnabled = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(PLPhotoBrowserCell.self, forCellWithReuseIdentifier: "PLPhotoBrowserCell")
        self.view.addSubview(self.collectionView)
        
        self.pageTipsLabel = UILabel()
        self.pageTipsLabel.textColor = .white
        self.pageTipsLabel.textAlignment = .center
        
        self.pageTipsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.pageTipsLabel.backgroundColor = .clear
        self.view.addSubview(self.pageTipsLabel)
        
        DispatchQueue.main.async {
            self.setup()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = self.view.bounds
        frame.size.width += self.itemSpacing
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = frame.size
        
        self.collectionView.frame = frame
        
        if #available(iOS 11.0, *) {
            self.pageTipsLabel.frame = .init(x: 0, y: self.view.bounds.height - self.view.safeAreaInsets.bottom - self.pageTipsLabel.font.lineHeight - 30, width: self.view.bounds.width, height: self.pageTipsLabel.font.lineHeight)
        } else {
            // Fallback on earlier versions
        }
    }
    
    /// 设置下载图片方法
    ///
    /// - Parameter callback:
    func setDownloadImageCallback(_ callback: @escaping PLPhotoBrowserDownloadCallback) {
        self.downloadCallback = callback
    }
    
    /// 设置当前显示第几页
    ///
    /// - Parameter pageIndex:
    func setCurrentPageIndex(_ pageIndex: Int) {
        guard self.currentPageIndex != pageIndex else {
            return
        }
        self.currentPageIndex = pageIndex
        self.collectionView.setContentOffset(.init(x: CGFloat(pageIndex) * self.collectionView.frame.width, y: 0), animated: true)
    }
    
    
    /// 获取当前浏览界面
    ///
    /// - Returns:
    fileprivate func currentBrowserPage() -> PLPhotoBrowserPage {
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: self.currentPageIndex, section: 0)) as! PLPhotoBrowserCell
        return cell.page
    }
    
    /// 初始化配置
    fileprivate func setup() {
        self.collectionView.setContentOffset(.init(x: CGFloat(self.currentPageIndex) * self.collectionView.frame.width, y: 0), animated: true)
        self.updatePageTips()
    }
    
    /// 更新页数提示
    fileprivate func updatePageTips() {
        self.pageTipsLabel.text = "\(currentPageIndex + 1) / \(photos?.count ?? 0)"
    }
}


fileprivate class PLPhotoBrowserCell: UICollectionViewCell {
    
    weak var browser: PLPhotoBrowser?
    
    var waitIndicator: UIActivityIndicatorView!
    var page: PLPhotoBrowserPage!
    
    var photo: PLPhoto? {
        didSet {
            self.page.image = nil
            if let thumbnail = photo?.thumbnail {
                self.loadPhoto(thumbnail, isThumb: true)
            }
            
            if let datasource = photo?.data {
                self.loadPhoto(datasource, isThumb: false)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.page = PLPhotoBrowserPage()
        self.page.didSingleTapCallback = {[unowned self] _ in
            if self.browser?.enableSingleTapClose ?? false {
                self.browser?.dismiss(animated: true, completion: nil)
            }
        }
        
        self.page.longPressCallback = {[unowned self] _ in
            guard let image = self.page.image else {
                return
            }
            
            var activity: UIActivityViewController!
            if let yyImage = image as? YYImage {
                if yyImage.animatedImageType == .GIF {
                    activity = UIActivityViewController.init(activityItems: [yyImage.animatedImageData!], applicationActivities: nil)
                } else {
                    activity = UIActivityViewController.init(activityItems: [yyImage], applicationActivities: nil)
                }
            } else {
                activity = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
            }
            activity.excludedActivityTypes = [.print]
            activity.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            }
            self.browser?.present(activity, animated: true, completion: nil)
        }
        
        self.page.panCloseCallback = {[unowned self] _, progress in
            self.browser?.pageTipsLabel.alpha = 1 - progress
            self.browser?.view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress)
        }
        
        self.page.closedCallback = {[unowned self] _ in
            self.browser?.pageTipsLabel.alpha = 0
            self.browser?.dismiss(animated: true, completion: nil)
        }
        
        self.contentView.addSubview(self.page)
        
        self.waitIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        self.contentView.addSubview(self.waitIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var bounds = self.contentView.bounds
        bounds.size.width -= 10
        self.page.frame = bounds
        self.waitIndicator.center = .init(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    func loadPhoto(_ dataSource: PLPhotoDatasource, isThumb: Bool) {
        
        if let image = dataSource as? UIImage {
            self.page.image = image
            return
        }
        
        if let data = dataSource as? Data {
            let image = UIImage.init(data: data)
            self.page.image = image
            return
        }
        
        if let str = dataSource as? String, let url = URL.init(string: str) {
            self.parseURL(url, isThumb: isThumb)
            return
        }
        
        if let url = dataSource as? URL {
            self.parseURL(url, isThumb: isThumb)
            return
        }
        
        self.page.image = nil
    }
    
    func parseURL(_ url: URL, isThumb: Bool) {
        if url.isFileURL {
            guard let data = try? Data.init(contentsOf: url) else {
                return
            }
            
            let image = UIImage.init(data: data)
            self.page.image = image
        } else {
            self.waitIndicator.startAnimating()
            self.browser?.downloadCallback?(url, isThumb, {[weak self] image in
                self?.waitIndicator.stopAnimating()
                self?.page.image = image
            })
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PLPhotoBrowser: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PLPhotoBrowserCell", for: indexPath) as! PLPhotoBrowserCell
        cell.browser = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PLPhotoBrowserCell {
            cell.photo = self.photos?[indexPath.row]
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PLPhotoBrowser: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        self.currentPageIndex = page
    }
}

// MARK: - UIViewControllerTransitioningDelegate
class PLPhotoBrowserAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresent = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        // 获取view
        var browser: PLPhotoBrowser?
        var anotherView: UIView?
        var browserView: UIView?
        if self.isPresent {
            browser = transitionContext.viewController(forKey: .to) as? PLPhotoBrowser
            
            anotherView = transitionContext.view(forKey: .from)
            browserView = transitionContext.view(forKey: .to)
        } else {
            browser = transitionContext.viewController(forKey: .from) as? PLPhotoBrowser
            
            anotherView = transitionContext.view(forKey: .to)
            browserView = transitionContext.view(forKey: .from)
        }
        
        // 添加view
        if self.isPresent {
            if let view = anotherView {
                containerView.addSubview(view)
            }
            
            if let view = browserView {
                containerView.addSubview(view)
            }
        }
        
        // -- 动画
        let duration = self.transitionDuration(using: nil)
        
        // 没有fromview 或 截取失败 做简单的渐变动画
        if browser?.fromView == nil || browser?.fromView?.image == nil {
            if self.isPresent {
                
                browserView?.alpha = 0
                UIView.animate(withDuration: duration, animations: {
                    browserView?.alpha = 1
                }) { (_) in
                    transitionContext.completeTransition(true)
                }
            } else {
                UIView.animate(withDuration: duration, animations: {
                    browserView?.alpha = 0
                }) { (_) in
                    browserView?.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            }
            return
        }
        
        guard let fromView = browser?.fromView else {
            return
        }
        
        
        
        if self.isPresent {
            let snapshotView = UIImageView.init(image: browser?.fromView?.image)
            snapshotView.contentMode = browser?.fromView?.contentMode ?? .scaleToFill
            snapshotView.clipsToBounds = true
            
            let fromRect = fromView.superview?.convert(fromView.frame, to: browser!.view) ?? snapshotView.frame
            snapshotView.frame = fromRect
            containerView.addSubview(snapshotView)
            
            
            let targetSize = browser!.view.frame.size
            var toRect = snapshotView.frame
            toRect.size = PLPhotoBrowserPage.scale(fromSize: browser?.fromView?.image?.size ?? toRect.size, targetSize: targetSize)
            
            toRect.origin.x = (targetSize.width - toRect.width) / 2
            toRect.origin.y = (targetSize.height - toRect.height) / 2
            
            
            browser?.collectionView.isHidden = true
            browserView?.alpha = 0
            
            UIView.animate(withDuration: duration, animations: {
                snapshotView.frame = toRect
                browserView?.alpha = 1
            }) { (_) in
                browser?.collectionView.isHidden = false
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            
        } else {
            
            let imageView = browser?.currentBrowserPage().imageView
            let snapshotView = UIImageView.init(image: imageView?.image)
            snapshotView.contentMode = browser?.fromView?.contentMode ?? .scaleToFill
            snapshotView.clipsToBounds = true
            
            let fromRect = browser?.currentBrowserPage().convert(imageView!.frame, to: browser!.view) ?? imageView!.frame
            let toRect = fromView.superview?.convert(fromView.frame, to: browser!.view) ?? CGRect.zero
            
            snapshotView.frame = fromRect
            containerView.addSubview(snapshotView)
            
            browser?.collectionView.isHidden = true
            UIView.animate(withDuration: duration, animations: {
                snapshotView.frame = toRect
                browserView?.alpha = 0
            }) { (_) in
                browserView?.removeFromSuperview()
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}

extension PLPhotoBrowser: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let obj = PLPhotoBrowserAnimatedTransitioning()
        obj.isPresent = true
        return obj
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let obj = PLPhotoBrowserAnimatedTransitioning()
        obj.isPresent = false
        return obj
    }
}
