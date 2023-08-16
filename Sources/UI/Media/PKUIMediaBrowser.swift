//
//  PKUIMediaBrowser.swift
//  PKit
//
//  Created by Plumk on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit


open class PKUIMediaBrowser: UIViewController {
    
    /// 翻页Callback
    public typealias DidChangePageCallback = (PKUIMediaBrowser, Int)->Void
    
    /// 每页之间的间距
    open var pageSpacing: CGFloat = 10
    
    /// 启用单击关闭
    open var enableSingleTapClose: Bool = true
    
    /// 翻页回调
    open var didChangePageCallback: DidChangePageCallback?
    
    /// 来自哪一个view 与过渡动画有关
    open weak var fromImageView: UIImageView?
    
    /// 当前数据源
    open private(set) var mediaArray = [PKUIMedia]() {
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
    var collectionView: UICollectionView!
    open private(set) var pageTipsLabel: UILabel!
    
    /// 上一个cell
    private var preCell: PKUIMediaBrowserCell?
    
    public init(mediaArray: [PKUIMedia], initIndex: Int = 0, fromImageView: UIImageView? = nil) {
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
        self.collectionView.register(PKUIMediaBrowserCell.self, forCellWithReuseIdentifier: "PKUIMediaBrowserCell")
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
    func currentBrowserPage() -> PKUIMediaBrowserPage? {
        guard let cell = self.collectionView.cellForItem(at: IndexPath.init(row: self.currentPageIndex, section: 0)) as? PKUIMediaBrowserCell else {
            return nil
        }
        return cell.page
    }
    
    
    /// 更新页数提示
    func updatePageTips() {
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
extension PKUIMediaBrowser: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        guard let view = event.allTouches?.first?.view else {
            return true
        }
        
        return !view.isKind(of: UIControl.self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PKUIMediaBrowser: UICollectionViewDataSource, UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaArray.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let media = self.mediaArray[indexPath.row]
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PKUIMediaBrowserCell", for: indexPath) as! PKUIMediaBrowserCell
        cell.pageSpacing = self.pageSpacing
        
        let page = media.pk_pageClass.init(media: media)
        page.delegate = self
        cell.page = page
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.preCell == nil {
            // 第一次显示
            if let cell = cell as? PKUIMediaBrowserCell {
                cell.page?.didEnter()
                self.preCell = cell
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.collectionView.indexPathForItem(at: scrollView.contentOffset) else {
            return
        }
        
        guard let cell = self.collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        guard self.preCell != cell else {
            return
        }
        
        self.preCell?.page?.didLeave()
        if let cell = cell as? PKUIMediaBrowserCell {
            cell.page?.didEnter()
            self.preCell = cell
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDecelerating(scrollView)
    }
}

// MARK: - PKUIMediaBrowserPageDelete
extension PKUIMediaBrowser: PKUIMediaBrowserPageDelete {
    
    public func browserFromView() -> UIView? {
        return self.fromImageView
    }
    
    public func pagePanCloseProgressUpdate(_ page: PKUIMediaBrowserPage, progress: CGFloat) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress)
        self.pageTipsLabel.alpha = 1 - progress
    }
    
    public func pageDidClosed(_ page: PKUIMediaBrowserPage) {
        self.dismiss(animated: true)
    }
}


// MARK: - Class PLPhotoBrowserCell
fileprivate class PKUIMediaBrowserCell: UICollectionViewCell {
    
    var pageSpacing: CGFloat = 0
    var page: PKUIMediaBrowserPage? {
        didSet {
            oldValue?.removeFromSuperview()
            if let page = self.page {
                self.contentView.addSubview(page)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let page = self.page {
            var rect = self.contentView.bounds
            rect.size.width -= self.pageSpacing
            page.frame = rect
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PKUIMediaBrowser: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        self.currentPageIndex = page
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PKUIMediaBrowser: UIViewControllerTransitioningDelegate {
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let obj = PKUIMediaBrowserAnimatedTransitioning(isDismiss: false)
        return obj
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let obj = PKUIMediaBrowserAnimatedTransitioning(isDismiss: true)
        return obj
    }
}
