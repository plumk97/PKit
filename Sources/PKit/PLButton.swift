//
//  PLButton.swift
//  PLKit
//
//  Created by Plumk on 2019/4/26.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

@IBDesignable
open class PLButton: UIControl {
    
    open var title: String? {
        didSet {
            self.setup(oldValue != title)
        }
    }
    
    open var attributedTitle: NSAttributedString? {
        didSet {
            self.setup(oldValue != attributedTitle)
        }
    }
    
    open var titleColor: UIColor = .black {
        didSet {
            self.setup(false)
        }
    }
    
    open var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            self.setup(oldValue != font)
        }
    }
    open var backgroundImage: UIImage? {
        get { self.getBackgroundImage(.normal) }
        set {
            self.setBackgroundImage(newValue, state: .normal)
            self.setup(newValue != self.backgroundImage)
        }
    }
    
    
    open private(set) var leftIcon: Icon!
    open private(set) var topIcon: Icon!
    open private(set) var rightIcon: Icon!
    open private(set) var bottomIcon: Icon!
    
    /// 图标与文字的距离
    open var spaceingTitleImage: CGFloat = 2 {
        didSet {
            self.setup(oldValue != spaceingTitleImage)
        }
    }
    
    open var padding: UIEdgeInsets = .zero {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    open var borderColor: UIColor = .clear {
        didSet {
            self.setupLayer()
        }
    }
    
    open var borderWidth: CGFloat = 0 {
        didSet {
            self.setupLayer()
        }
    }
    
    open var alwayHalfRadius: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var cornerRadius: CGFloat = 0 {
        didSet {
            self.setupLayer()
        }
    }
    
    open var pointBoundsInset: UIEdgeInsets = .zero
    
    /// 背景状态组
    private var backgroundImageSet = [UIControl.State.RawValue: UIImage]()
    
    private var contentSize: CGSize = .zero
    private var contentView: UIView!
    
    open private(set) var titleLabel: UILabel!
    open private(set) var leftImageView: UIImageView!
    open private(set) var topImageView: UIImageView!
    open private(set) var rightImageView: UIImageView!
    open private(set) var bottomImageView: UIImageView!
    
    open private(set) var backgroundImageView: UIImageView!
    
    fileprivate var prevState: State = .normal
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commInit()
    }
    
    private func commInit() {
        
        self.clipsToBounds = true
        self.prevState = self.state
        self.leftIcon = Icon.init(button: self)
        self.topIcon = Icon.init(button: self)
        self.rightIcon = Icon.init(button: self)
        self.bottomIcon = Icon.init(button: self)
        
        self.backgroundImageView = UIImageView()
        self.addSubview(self.backgroundImageView)
        
        self.contentView = UIView()
        self.contentView.isUserInteractionEnabled = false
        self.addSubview(self.contentView)
        
        self.titleLabel = UILabel()
        self.contentView.addSubview(self.titleLabel)
        
        self.leftImageView = UIImageView()
        self.leftIcon.relImageView = self.leftImageView
        self.contentView.addSubview(self.leftImageView)
        
        self.topImageView = UIImageView()
        self.topIcon.relImageView = self.topImageView
        self.contentView.addSubview(self.topImageView)
        
        self.rightImageView = UIImageView()
        self.rightIcon.relImageView = self.rightImageView
        self.contentView.addSubview(self.rightImageView)
        
        self.bottomImageView = UIImageView()
        self.bottomIcon.relImageView = self.bottomImageView
        self.contentView.addSubview(self.bottomImageView)
        
        self.setup()
        self.addLoopObserve()
    }
    
    private func addLoopObserve() {
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.beforeWaiting.rawValue, true, 0) {[weak self] (observer, activity) in
            guard self != nil else {
                CFRunLoopObserverInvalidate(observer)
                CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                return
            }
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                self?.renewAppearance()
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
    
    fileprivate func renewAppearance(isForce: Bool = false) {
        guard self.prevState != self.state || isForce else {
            return
        }
        
        self.leftIcon.renewImageViewImage()
        self.topIcon.renewImageViewImage()
        self.rightIcon.renewImageViewImage()
        self.bottomIcon.renewImageViewImage()
        
        if let img = self.backgroundImageSet[self.state.rawValue] {
            self.backgroundImageView.image = img
        } else {
            self.backgroundImageView.image = self.backgroundImage
        }
        
        self.prevState = self.state
    }
    
    fileprivate func setupLayer() {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
    }
    
    fileprivate func setup(_ isRenewLayout: Bool = true) {
        if self.attributedTitle != nil {
            self.titleLabel.attributedText = self.attributedTitle
        } else {
            self.titleLabel.text = self.title
            self.titleLabel.textColor = self.titleColor
            self.titleLabel.font = self.font
        }
        
        self.renewAppearance(isForce: true)
        
        if isRenewLayout {
            self.relayoutContentView()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    fileprivate func relayoutContentView() {
        
        // - 设置Size
        var contentSize: CGSize = .zero
        
        self.titleLabel.sizeToFit()
        contentSize.width += self.titleLabel.frame.width
        contentSize.height += self.titleLabel.frame.height
        
        self.leftImageView.bounds.size = .zero
        if self.leftImageView.image != nil {
            self.leftImageView.bounds.size = self.leftIcon.imageSize ?? self.leftImageView.image!.size
            
            contentSize.height = max(self.leftImageView.bounds.height, contentSize.height)
            contentSize.width += self.leftImageView.bounds.width + self.spaceingTitleImage
        }
        
        self.topImageView.bounds.size = .zero
        if self.topImageView.image != nil {
            self.topImageView.bounds.size = self.topIcon.imageSize ?? self.topImageView.image!.size
            
            contentSize.width = max(self.topImageView.bounds.width, contentSize.width)
            contentSize.height += self.topImageView.bounds.height + self.spaceingTitleImage
        }
        
        self.rightImageView.bounds.size = .zero
        if self.rightImageView.image != nil {
            self.rightImageView.bounds.size = self.rightIcon.imageSize ?? self.rightImageView.image!.size
            
            contentSize.height = max(self.rightImageView.bounds.height, contentSize.height)
            contentSize.width += self.rightImageView.bounds.width + self.spaceingTitleImage
        }
        
        self.bottomImageView.bounds.size = .zero
        if self.bottomImageView.image != nil {
            self.bottomImageView.bounds.size = self.bottomIcon.imageSize ?? self.bottomImageView.image!.size
            
            contentSize.width = max(self.bottomImageView.bounds.width, contentSize.width)
            contentSize.height += self.rightImageView.bounds.height + self.spaceingTitleImage
        }
        
        if contentSize.equalTo(.zero) && self.backgroundImageView.image != nil {
            contentSize = self.backgroundImageView.sizeThatFits(.zero)
        }
        
        self.contentSize = contentSize
        self.contentView.frame.size = contentSize
        
        // - 设置origin
        var titleOrigin = CGPoint.zero
        
        if self.leftImageView.image != nil && self.rightImageView.image != nil {
            titleOrigin.x = (contentSize.width - self.titleLabel.bounds.width) / 2
        } else if self.leftImageView.image != nil {
            titleOrigin.x = contentSize.width - self.titleLabel.bounds.width
        } else if self.rightImageView.image != nil {
            titleOrigin.x = 0
        } else {
            titleOrigin.x = (contentSize.width - self.titleLabel.bounds.width) / 2
        }
        
        if self.topImageView.image != nil && self.bottomImageView.image != nil {
            titleOrigin.y = (contentSize.height - self.titleLabel.bounds.height) / 2
        } else if self.topImageView.image != nil {
            titleOrigin.y = contentSize.height - self.titleLabel.bounds.height
        } else if self.bottomImageView.image != nil {
            titleOrigin.y = 0
        } else {
            titleOrigin.y = (contentSize.height - self.titleLabel.bounds.height) / 2
        }
        
        self.titleLabel.frame.origin = titleOrigin
        
        
        let titleRect = self.titleLabel.frame
        if self.leftImageView.image != nil {
            let rect = self.leftImageView.frame
            let y = (contentSize.height - rect.height) / 2
            self.leftImageView.frame.origin = .init(x: titleRect.minX - rect.width - self.spaceingTitleImage, y: y)
        }
        
        
        if self.rightImageView.image != nil {
            let rect = self.rightImageView.frame
            let y = (contentSize.height - rect.height) / 2
            self.rightImageView.frame.origin = .init(x: titleRect.maxX + self.spaceingTitleImage, y: y)
        }
        
        if self.topImageView.image != nil {
            let rect = self.topImageView.frame
            let x = (contentSize.width - rect.width) / 2
            self.topImageView.frame.origin = .init(x: x, y: titleRect.minY - rect.height - self.spaceingTitleImage)
        }
        
        if self.bottomImageView.image != nil {
            let rect = self.bottomImageView.frame
            let x = (contentSize.width - rect.width) / 2
            self.bottomImageView.frame.origin = .init(x: x, y: titleRect.maxY + self.spaceingTitleImage)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.frame = self.bounds
        if self.alwayHalfRadius {
            self.cornerRadius = self.bounds.height / 2
        }
        
        var bounds = self.bounds
        bounds.size.width -= self.padding.left + self.padding.right
        bounds.size.height -= self.padding.top + self.padding.bottom
        
        var rect = self.contentView.frame
        rect.origin.x = self.padding.left + (bounds.width - rect.width) / 2
        rect.origin.y = self.padding.top + (bounds.height - rect.height) / 2
        
        self.contentView.frame = rect
    }
    
    // MARK: - Size Fit
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = self.contentSize
        size.width += self.padding.left + self.padding.right
        size.height += self.padding.top + self.padding.bottom
        
        return size
    }
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.bounds.inset(by: self.pointBoundsInset).contains(point)
    }
}

// MARK: - Public
extension PLButton {
    
    public func setBackgroundImage(_ image: UIImage?, state: UIControl.State) {
        self.backgroundImageSet[state.rawValue] = image
        self.renewAppearance(isForce: state == self.state)
    }
    
    public func getBackgroundImage(_ state: UIControl.State) -> UIImage? {
        return self.backgroundImageSet[state.rawValue]
    }
}


// MARK: - Icon
extension PLButton {
    
    open class Icon: NSObject {
        open var image: UIImage? {
            set {
                
                let oldValue = self.imageSet[UIControl.State.normal.rawValue]
                self.setImage(newValue, state: .normal)
                
                if let o = oldValue, let n = newValue {
                    self.button?.setup(!o.size.equalTo(n.size))
                } else if oldValue != newValue {
                    self.button?.setup(true)
                } else {
                    self.button?.setup(false)
                }
            }
            
            get {
                return self.getImage(state: .normal)
            }
        }
        
        open var imageSize: CGSize? {
            didSet {
                if let o = oldValue, let n = imageSize {
                    self.button?.setup(!o.equalTo(n))
                } else {
                    self.button?.setup()
                }
            }
        }
        
        private var imageSet = [UIControl.State.RawValue: UIImage]()
        
        fileprivate weak var button: PLButton?
        fileprivate weak var relImageView: UIImageView?
        
        fileprivate init(button: PLButton?) {
            super.init()
            self.button = button
        }
        
        fileprivate func renewImageViewImage() {
            guard let imageView = self.relImageView else {
                return
            }
            
            guard let btn = self.button else {
                return
            }
            
            if let img = self.getImage(state: btn.state) {
                imageView.image = img
            } else {
                imageView.image = self.image
            }
        }
    }
}



// MARK: - Icon Public
extension PLButton.Icon {
    
    open func setImage(_ image: UIImage?, state: UIControl.State) {
        if image == nil {
            self.imageSet.removeValue(forKey: state.rawValue)
            self.button?.renewAppearance(isForce: state == self.button?.state)
        } else {
            self.imageSet[state.rawValue] = image
        }
    }
    
    open func getImage(state: UIControl.State) -> UIImage? {
        return self.imageSet[state.rawValue]
    }
}

