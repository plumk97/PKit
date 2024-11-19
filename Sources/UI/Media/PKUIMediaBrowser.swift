//
//  PKUIMediaBrowser.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import UIKit

open class PKUIMediaBrowser: UIViewController {
    
    
    public var transitioningView: ((_ browser: PKUIMediaBrowser) -> UIView?)?
    public var indexChanged: ((_ browser: PKUIMediaBrowser) -> Void)?
    
    
    public private(set) var medias = [PKUIMedia]()
    
    ///
    public var defaultIndex: Int = 0
    
    ///
    public private(set) var currentPageIndex: Int = 0 {
        didSet {
            self.indexChanged?(self)
        }
    }
    
    public init(medias: [PKUIMedia], defaultIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        self.medias = medias
        self.defaultIndex = defaultIndex
        self.commInit()
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    open func commInit() {
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self
    }
    
    
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.register(PKUIMediaBrowserCell.self, forCellWithReuseIdentifier: "PKUIMediaBrowserCell")
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(self.collectionView)
        
        self.currentPageIndex = self.defaultIndex
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(.init(x: CGFloat(self.currentPageIndex) * self.collectionView.frame.width, y: 0), animated: true)
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = self.view.bounds
        frame.size.width += 10
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = frame.size
        
        self.collectionView.frame = frame
        self.collectionView.setContentOffset(.init(x: CGFloat(self.currentPageIndex) * self.collectionView.frame.width, y: 0), animated: false)
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PKUIMediaBrowser: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.medias.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.medias[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PKUIMediaBrowserCell", for: indexPath) as! PKUIMediaBrowserCell
        cell.media = media
        cell.page?.delegate = self
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PKUIMediaBrowserCell {
            cell.page?.didEnter()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PKUIMediaBrowserCell {
            cell.page?.didLeave()
        }
    }
}


// MARK: - UIViewControllerTransitioningDelegate
extension PKUIMediaBrowser: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let obj = PKUIMediaBrowserTransitioning(isDismiss: false)
        return obj
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let obj = PKUIMediaBrowserTransitioning(isDismiss: true)
        return obj
    }
}

// MARK: - UIScrollViewDelegate
extension PKUIMediaBrowser: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        if page != self.currentPageIndex {
            self.currentPageIndex = page
        }
    }
}


// MARK: - PKUIMediaBrowserPageDelegate
extension PKUIMediaBrowser: PKUIMediaBrowserPageDelegate {
    public func pageDidClosed(_ page: PKUIMediaBrowserPage) {
        self.dismiss(animated: true)
    }
    
    public func pagePanCloseProgressUpdate(_ page: PKUIMediaBrowserPage, progress: CGFloat) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress)
    }
}
