//
//  PLPageScrollViewContainer.swift
//  PLKit
//
//  Created by 李铁柱 on 2019/6/3.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

protocol PLPageScrollViewContainerRow {
    func scrollView() -> UIScrollView
}

extension UIScrollView: PLPageScrollViewContainerRow {
    func scrollView() -> UIScrollView {
        return self
    }
}

@objc protocol PLPageScrollViewContainerDelegate: NSObjectProtocol {
    @objc func pageScrollViewContainerWillDragging(_ container: PLPageScrollViewContainer)
    @objc func pageScrollViewContainerEndDragging(_ container: PLPageScrollViewContainer)
    
    @objc func pageScrollViewContainer(_ container: PLPageScrollViewContainer, didSubScrollView scrollView: UIScrollView)
}

class PLPageScrollViewContainer: UICollectionView {
    
    var containerDelegate: PLPageScrollViewContainerDelegate?
    var rows: [PLPageScrollViewContainerRow]? {
        didSet {
            self.updateRows(oldRows: oldValue)
        }
    }
    
    private(set) var currentIndex: Int = 0
    var currentRow: PLPageScrollViewContainerRow? {
        return self.rows?[self.currentIndex]
    }
    
    private var dragCacheScrollEnabled: Bool = false
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.commInit()
    }
    
    fileprivate func commInit() {
        self.backgroundColor = .clear
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        self.bounces = false
        self.isPagingEnabled = true
        
        self.register(PLPageScrollViewContainerCell.self, forCellWithReuseIdentifier: "Cell")
        self.dataSource = self
        self.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = self.bounds.size
            layout.minimumLineSpacing =  0
            layout.minimumInteritemSpacing = 0
        }
    }
    
    fileprivate func updateRows(oldRows: [PLPageScrollViewContainerRow]?) {
        
        if let rows = oldRows {
            self.removePanKVO(rows: rows)
        }
        
        if let rows = self.rows {
            self.addPanKVO(rows: rows)
        }
        self.reloadData()
    }

    func setCurrentIndex(_ index: Int, animated: Bool = true) {
        guard index != self.currentIndex else {
            return
        }
        
        self.currentIndex = index
        self.setContentOffset(.init(x: CGFloat(index) * self.bounds.width, y: 0), animated: animated)
    }
    
    // MARK: - KVO
    fileprivate func addPanKVO(rows: [PLPageScrollViewContainerRow]) {
        rows.forEach { (row) in
            row.scrollView().addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            row.scrollView().panGestureRecognizer.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
    }
    
    fileprivate func removePanKVO(rows: [PLPageScrollViewContainerRow]) {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "state" {
            guard self.currentRow?.scrollView().panGestureRecognizer.isEqual(object) ?? false else {
                return
            }
            
            if let state = self.currentRow?.scrollView().panGestureRecognizer.state {
                if state == .ended || state == .cancelled {
                    self.isScrollEnabled = true
                } else if state == .changed {
                    self.isScrollEnabled = false
                }
            }
        }
        
        if keyPath == "contentOffset" {
            guard let scrollView = self.currentRow?.scrollView() else {
                return
            }
            
            guard scrollView.isEqual(object) else {
                return
            }
            
            self.containerDelegate?.pageScrollViewContainer(self, didSubScrollView: scrollView)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PLPageScrollViewContainer: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rows?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PLPageScrollViewContainerCell
        cell.scrollView = self.rows?[indexPath.row].scrollView()
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dragCacheScrollEnabled = self.currentRow?.scrollView().isScrollEnabled ?? false
        self.currentRow?.scrollView().isScrollEnabled = false
        self.containerDelegate?.pageScrollViewContainerWillDragging(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.currentRow?.scrollView().isScrollEnabled = self.dragCacheScrollEnabled
        self.containerDelegate?.pageScrollViewContainerEndDragging(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
}



fileprivate class PLPageScrollViewContainerCell: UICollectionViewCell {
    
    var scrollView: UIScrollView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let unview = scrollView {
                self.contentView.addSubview(unview)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView?.frame = self.bounds
    }
}
