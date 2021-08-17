//
//  PLMediaBrowser.swift
//  PLKit
//
//  Created by mini2019 on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import YYImage


open class PLMediaBrowser: UIViewController {
    
    /// 翻页Callback
    public typealias DidChangePageCallback = (PLMediaBrowser, Int)->Void
    
    /// 每页之间的间距
    open var pageSpacing: CGFloat = 10
    
    /// 启用单击关闭
    open var enableSingleTapClose: Bool = true
    
    /// 翻页回调
    open var didChangePageCallback: DidChangePageCallback?
    
    /// 来自哪一个view 与过渡动画有关
    open weak var fromImageView: UIImageView?
    
    /// 当前数据源
    open private(set) var mediaArray = [PLMedia]() {
        didSet {
            self.updatePageTips()
        }
    }
    
    /// 当前第几页
    open private(set) var currentPageIndex: Int = 0 {
        didSet {
            self.updatePageTips()
            if oldValue != currentPageIndex {
                self.didChangePageCallback?(self, currentPageIndex)
            }
        }
    }
    
    // --
    fileprivate var collectionView: UICollectionView!
    open fileprivate(set) var pageTipsLabel: UILabel!
    
    public init(mediaArray: [PLMedia], initIndex: Int = 0, fromImageView: UIImageView? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.fromImageView = fromImageView
        self.mediaArray = mediaArray
        self.currentPageIndex = initIndex
        
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commInit()
    }
    
    fileprivate func commInit() {
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        var bounds = self.view.bounds
        bounds.size.width += self.pageSpacing
        
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
        self.collectionView.bounces = false
        self.collectionView.register(PLMediaBrowserCell.self, forCellWithReuseIdentifier: "PLMediaBrowserCell")
        self.view.addSubview(self.collectionView)
        
        self.pageTipsLabel = UILabel()
        self.pageTipsLabel.textColor = .white
        self.pageTipsLabel.textAlignment = .center
        
        self.pageTipsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.pageTipsLabel.backgroundColor = .clear
        self.view.addSubview(self.pageTipsLabel)
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(.init(x: CGFloat(self.currentPageIndex) * self.collectionView.frame.width, y: 0), animated: true)
            self.updatePageTips()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = self.view.bounds
        frame.size.width += self.pageSpacing
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = frame.size
        
        self.collectionView.frame = frame
        self.collectionView.setContentOffset(.init(x: CGFloat(self.currentPageIndex) * self.collectionView.frame.width, y: 0), animated: false)
        
        if #available(iOS 11.0, *) {
            let safeArea = self.view.safeAreaInsets
            self.pageTipsLabel.frame = .init(x: 0, y: self.view.bounds.height - safeArea.bottom - self.pageTipsLabel.font.lineHeight - 30,
                                             width: self.view.bounds.width, height: self.pageTipsLabel.font.lineHeight)
        }
    }
    
    
    /// 设置当前显示第几页
    ///
    /// - Parameter pageIndex:
    open func setCurrentPageIndex(_ pageIndex: Int) {
        guard self.currentPageIndex != pageIndex else {
            return
        }
        self.currentPageIndex = pageIndex
        self.collectionView.setContentOffset(.init(x: CGFloat(pageIndex) * self.collectionView.frame.width, y: 0), animated: true)
    }
    
    /// 获取当前浏览界面
    ///
    /// - Returns:
    fileprivate func currentBrowserPage() -> PLMediaBrowserPage? {
        guard let cell = self.collectionView.cellForItem(at: IndexPath.init(row: self.currentPageIndex, section: 0)) as? PLMediaBrowserCell else {
            return nil
        }
        return cell.page
    }
    
    
    /// 更新页数提示
    fileprivate func updatePageTips() {
        self.pageTipsLabel.text = "\(self.currentPageIndex + 1) / \(self.mediaArray.count)"
    }
    
    // MARK: - StatusBar 保证状态栏显示正确
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if flag {
                UIView.animate(withDuration: 0.25) {
                    rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            } else {
                rootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
            
            completion?()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PLMediaBrowser: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        guard let view = event.allTouches?.first?.view else {
            return true
        }
        
        return !view.isKind(of: UIControl.self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PLMediaBrowser: UICollectionViewDataSource, UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaArray.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PLMediaBrowserCell", for: indexPath) as! PLMediaBrowserCell
        cell.browser = self
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PLMediaBrowserCell {
            cell.willDisplay(media: self.mediaArray[indexPath.row])
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PLMediaBrowserCell {
            cell.didEndDisplaying()
        }
    }
}

// MARK: - Class PLPhotoBrowserCell
fileprivate class PLMediaBrowserCell: UICollectionViewCell {
    weak var browser: PLMediaBrowser!
    var page: PLMediaBrowserPage?
    
    func willDisplay(media: PLMedia) {
        self.page?.removeFromSuperview()
        self.page = nil
        
        let page = media.pl_pageClass.init(media: media)
        self.contentView.addSubview(page)
        
        page.closeProgressCallback = {[unowned self] _, progress in
            self.browser.pageTipsLabel.alpha = 1 - progress
            self.browser.view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress)
        }

        page.closedCallback = {[unowned self] _, isTapClose in
            if isTapClose {
                if !self.browser.enableSingleTapClose {
                    return
                }
            }
            self.browser.pageTipsLabel.alpha = 0
            self.browser.dismiss(animated: true, completion: nil)
        }
        
        self.page = page
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func didEndDisplaying() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var rect = self.contentView.bounds
        rect.size.width -= self.browser.pageSpacing
        self.page?.frame = rect
    }
    
}




// MARK: - UIScrollViewDelegate
extension PLMediaBrowser: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        self.currentPageIndex = page
    }
}

// MARK: - UIViewControllerTransitioningDelegate
open class PLMediaBrowserAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    open var isPresent = false
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        containerView.frame = UIScreen.main.bounds
        
        // 获取view
        var browser: PLMediaBrowser!
        
        var anotherView: UIView!
        var browserView: UIView!
        
        if self.isPresent {
            browser = transitionContext.viewController(forKey: .to) as? PLMediaBrowser

            anotherView = transitionContext.view(forKey: .from)
            browserView = transitionContext.view(forKey: .to)
        } else {
            browser = transitionContext.viewController(forKey: .from) as? PLMediaBrowser

            anotherView = transitionContext.view(forKey: .to)
            browserView = transitionContext.view(forKey: .from)
        }

        // 添加view
        if self.isPresent {
            if let view = anotherView {
                containerView.addSubview(view)
            }

            if let view = browserView {
                view.frame = containerView.bounds
                containerView.addSubview(view)
            }
        }

        // -- 动画
        let duration = self.transitionDuration(using: nil)

        if self.isPresent {
            
            guard let fromImageView = browser.fromImageView, fromImageView.image != nil else {
                browserView.alpha = 0
                UIView.animate(withDuration: duration, animations: {
                    browserView.alpha = 1
                }) { (_) in
                    transitionContext.completeTransition(true)
                }
                return
            }
            
            let snapshotView = UIImageView.init(image: fromImageView.image)
            snapshotView.contentMode = fromImageView.contentMode
            snapshotView.clipsToBounds = true

            let fromRect = fromImageView.superview?.convert(fromImageView.frame, to: browser.view) ?? snapshotView.frame
            snapshotView.frame = fromRect
            containerView.addSubview(snapshotView)


            let imageSize = fromImageView.image!.size
            let targetSize = browser!.view.frame.size
            var toRect = snapshotView.frame
            
            toRect.size = PLMediaBrowserPage.fitSize(imageSize, targetSize: targetSize)

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
            
            guard let fromImageView = browser.fromImageView,
                  let currentPage = browser.currentBrowserPage(),
                  let coverImage = currentPage.coverImage else {
                
                UIView.animate(withDuration: duration, animations: {
                    browserView.alpha = 0
                }) { (_) in
                    browserView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
                return
            }
            
            let snapshotView = UIImageView.init(image: coverImage)
            snapshotView.contentMode = fromImageView.contentMode
            snapshotView.clipsToBounds = true

            let fromRect = currentPage.convert(currentPage.contentView.frame, to: browser.view)
            let toRect = fromImageView.superview?.convert(fromImageView.frame, to: browser!.view) ?? CGRect.zero

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

// MARK: - UIViewControllerTransitioningDelegate
extension PLMediaBrowser: UIViewControllerTransitioningDelegate {
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let obj = PLMediaBrowserAnimatedTransitioning()
        obj.isPresent = true
        return obj
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let obj = PLMediaBrowserAnimatedTransitioning()
        obj.isPresent = false
        return obj
    }
}
