//
//  PKUIRecycleScrollView.swift
//  PKit
//
//  Created by Plumk on 2023/12/12.
//

import UIKit

open class PKUIRecycleScrollView: UIView {

    public typealias DidChangeIndexCallback = (_ index: Int, _ oldIndex: Int) -> Void
    public typealias DidClickCallBack = (_ index: Int, _ view: UIView) -> Void
    
    open var views = [UIView]() {
        didSet {
            
            for i in 0 ..< oldValue.count {
                self.collectionView.register(nil as AnyClass?, forCellWithReuseIdentifier: "cell\(i)")
            }
            
            for i in 0 ..< self.views.count {
                self.collectionView.register(Cell.self, forCellWithReuseIdentifier: "cell\(i)")
            }
            self.collectionView.reloadData()
            self.resetOffset()
        }
    }
    
    ///
    public var didChangeIndexCallback: DidChangeIndexCallback?
    
    ///
    public var didClickCallback: DidClickCallBack?
    
    
    public private(set) var index: Int = 0 {
        didSet {
            self.didChangeIndexCallback?(self.index, oldValue)
        }
    }
    
    ///
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    open func commInit() {
        self.clipsToBounds = true
        self.addSubview(self.collectionView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = self.bounds.size
        }
        self.resetOffset()
    }
    

    open func setIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < self.views.count && index != self.index else {
            return
        }
        
        self.index = index
        if self.views.count > 1 {
            let groupWidth = self.bounds.width * CGFloat(self.views.count)
            
            var offset = CGPoint(x: groupWidth, y: 0)
            offset.x += CGFloat(index) * self.bounds.width
            self.collectionView.setContentOffset(offset, animated: animated)
            
        } else {
            
            var offset = CGPoint(x: CGFloat(index) * self.bounds.width, y: 0)
            self.collectionView.setContentOffset(offset, animated: animated)
        }
        
    }
    
    func resetOffset() {
        guard self.bounds.width > 0 else {
            return
        }
        
        var offset = self.collectionView.contentOffset
        
        if self.views.count > 1 {
            let groupWidth = self.bounds.width * CGFloat(self.views.count)
            
            if offset.x < groupWidth {
                offset.x = groupWidth + offset.x
                self.collectionView.setContentOffset(offset, animated: false)
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
                
            } else if offset.x >= groupWidth * 2 {
                offset.x = offset.x - groupWidth
                self.collectionView.setContentOffset(offset, animated: false)
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            }
            
            let index = Int((offset.x - groupWidth) / self.bounds.width)
            if self.index != index {
                self.index = index
            }
        } else {
            
            let index = Int(offset.x / self.bounds.width)
            if self.index != index {
                self.index = index
            }
        }
        
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PKUIRecycleScrollView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.views.count > 1 else {
            return self.views.count
        }
        
        return self.views.count * 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell\(indexPath.row % self.views.count)", for: indexPath) as! Cell
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! Cell
        cell.view = self.views[indexPath.row % self.views.count]
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let view = self.views[indexPath.row % self.views.count]
        self.didClickCallback?(indexPath.row % self.views.count, view)
    }
}


// MARK: - UIScrollViewDelegate
extension PKUIRecycleScrollView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.resetOffset()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.resetOffset()
    }
}


// MARK: - Cell
extension PKUIRecycleScrollView {
    class Cell: UICollectionViewCell {
        
        var view: UIView? {
            didSet {

                oldValue?.removeFromSuperview()
                self.view?.removeFromSuperview()
                
                if let view = self.view {
                    self.contentView.addSubview(view)
                }
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.view?.frame = self.contentView.bounds
        }
    }
}
