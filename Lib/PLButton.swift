//
//  PLButton.swift
//  PLKit
//
//  Created by iOS on 2019/4/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLButton: UIControl {
    
    var title: String? {
        didSet {
            self.setup()
        }
    }
    
    var attributedTitle: NSAttributedString? {
        didSet {
            self.setup()
        }
    }
    
    var titleColor: UIColor = .black {
        didSet {
            self.setup()
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            self.setup()
        }
    }
    
    private(set) var leftIcon: Icon!
    private(set) var topIcon: Icon!
    private(set) var rightIcon: Icon!
    private(set) var bottomIcon: Icon!
    
    var spaceingTitleImage: CGFloat = 2 {
        didSet {
            self.setup()
        }
    }
    var spaceingEdge: UIEdgeInsets = .zero {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    var borderColor: UIColor = .clear{
        didSet {
            self.setupLayer()
        }
    }
    
    var borderWidth: CGFloat = 0{
        didSet {
            self.setupLayer()
        }
    }
    
    var alwayHalfRadius: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.setupLayer()
        }
    }
    
    var pointBoundsInset: UIEdgeInsets = .zero
    
    private var contentSize: CGSize = .zero
    private var contentView: UIView!
    private(set) var titleLabel: UILabel!
    private(set) var leftImageView: UIImageView!
    private(set) var topImageView: UIImageView!
    private(set) var rightImageView: UIImageView!
    private(set) var bottomImageView: UIImageView!
    
    private(set) var backgroundImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addLoopObserve() {
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.allActivities.rawValue, true, 0) {[weak self] (observer, activity) in
            guard self != nil else {
                CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                return
            }
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                self?.renewAppearance()
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
    
    fileprivate var prevState: State = .normal
    fileprivate func renewAppearance() {
        guard self.prevState != self.state else {
            return
        }
        
        self.leftIcon.renewImageViewImage()
        self.topIcon.renewImageViewImage()
        self.rightIcon.renewImageViewImage()
        self.bottomIcon.renewImageViewImage()
        
        self.prevState = self.state
    }
    
    fileprivate func setupLayer() {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
    }
    
    fileprivate func setup() {
        if self.attributedTitle != nil {
            self.titleLabel.attributedText = self.attributedTitle
        } else {
            self.titleLabel.text = self.title
            self.titleLabel.textColor = self.titleColor
            self.titleLabel.font = self.font
        }
        
        self.leftIcon.renewImageViewImage()
        self.topIcon.renewImageViewImage()
        self.rightIcon.renewImageViewImage()
        self.bottomIcon.renewImageViewImage()
        
        self.relayoutContentView()
        self.invalidateIntrinsicContentSize()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.frame = self.bounds
        if self.alwayHalfRadius {
            self.cornerRadius = self.bounds.height / 2
        }
        
        var bounds = self.bounds
        bounds.size.width -= self.spaceingEdge.left + self.spaceingEdge.right
        bounds.size.height -= self.spaceingEdge.top + self.spaceingEdge.bottom
        
        var rect = self.contentView.frame
        rect.origin.x = self.spaceingEdge.left + (bounds.width - rect.width) / 2
        rect.origin.y = self.spaceingEdge.top + (bounds.height - rect.height) / 2
        
        self.contentView.frame = rect
    }
    
    // MARK: - Size Fit
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
    
    override var intrinsicContentSize: CGSize {
        var size = self.contentSize
        size.width += self.spaceingEdge.left + self.spaceingEdge.right
        size.height += self.spaceingEdge.top + self.spaceingEdge.bottom
        
        return size
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.bounds.inset(by: self.pointBoundsInset).contains(point)
    }
}

extension PLButton {
    
    class Icon: NSObject {
        var image: UIImage? {
            set {
                self.setImage(newValue, state: .normal)
                self.button?.setup()
            }
            
            get {
                return self.getImage(state: .normal)
            }
        }
        
        var imageSize: CGSize? {
            didSet {
                self.button?.setup()
            }
        }
        
        private var imageSet = [UIControl.State.RawValue: UIImage?]()
        
        fileprivate weak var button: PLButton?
        fileprivate weak var relImageView: UIImageView?
        
        fileprivate init(button: PLButton?) {
            super.init()
            self.button = button
        }
        
        func setImage(_ image: UIImage?, state: UIControl.State) {
            self.imageSet[state.rawValue] = image
        }
        
        func getImage(state: UIControl.State) -> UIImage? {
            return self.imageSet[state.rawValue] ?? nil
        }
        
        
        fileprivate func renewImageViewImage() {
            guard let imageView = self.relImageView else {
                return
            }
            
            guard let btn = self.button else {
                return
            }
            
            if let img = self.imageSet[btn.state.rawValue] {
                imageView.image = img
            }
        }
    }
}
