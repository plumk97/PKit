//
//  PKUIButton.swift
//  PKit
//
//  Created by Plumk on 2019/4/26.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

@IBDesignable
open class PKUIButton: UIControl {
    
    /// 状态改变回调
    public var stateChangedCallback: ((_ state: UIControl.State) -> Void)?
    
    open var title: String? {
        set { self.setTitle(newValue, state: .normal) }
        get { self.getTitle(.normal) }
    }
    
    open var attributedTitle: NSAttributedString? {
        set { self.setAttributedTitle(newValue, state: .normal) }
        get { self.getAttributedTitle(.normal) }
    }
    
    open var titleColor: UIColor? {
        set { self.setTitleColor(newValue, state: .normal) }
        get { self.getTitleColor(.normal) }
    }
    
    open var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            self.titleLabel.font = self.font
            self.update(isUpdateAppearance: false)
        }
    }
    
    open var backgroundImage: UIImage? {
        set { self.setBackgroundImage(newValue, state: .normal) }
        get { self.getBackgroundImage(.normal) }
    }
    
    /// 图标与文字的距离
    open var spaceingTitleImage: CGFloat = 2 {
        didSet { self.update(isUpdateLayout: oldValue != spaceingTitleImage) }
    }
    
    /// 与内容距离
    open var padding: UIEdgeInsets = .zero {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    open var borderColor: UIColor = .clear {
        didSet {
            self.updateLayer()
        }
    }
    
    open var borderWidth: CGFloat = 0 {
        didSet {
            self.updateLayer()
        }
    }
    
    /// 是否总是保持高度一半的圆角
    open var alwayHalfRadius: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 圆角
    open var cornerRadius: CGFloat = 0 {
        didSet {
            self.updateLayer()
        }
    }
    
    /// 点击范围扩大
    open var pointBoundsInset: UIEdgeInsets = .zero
    
    public let titleLabel = UILabel()
    public let leftIcon = Icon()
    public let topIcon = Icon()
    public let rightIcon = Icon()
    public let bottomIcon = Icon()
    
    
    public let lImageView = UIImageView()
    public let tImageView = UIImageView()
    public let rImageView = UIImageView()
    public let bImageView = UIImageView()
    
    public let backgroundImageView = UIImageView()
    
    private var contentSize: CGSize = .zero
    private let contentView = UIView()
    private var prevState: State = .normal
    
    private var titleSet = [UIControl.State.RawValue: String]()
    private var titleColorSet = [UIControl.State.RawValue: UIColor]()
    private var attributedTitleSet = [UIControl.State.RawValue: NSAttributedString]()
    
    /// 背景状态组
    private var backgroundImageSet = [UIControl.State.RawValue: UIImage]()
    
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
        
        self.addSubview(self.backgroundImageView)
        
        self.contentView.isUserInteractionEnabled = false
        self.addSubview(self.contentView)
        
        self.titleLabel.font = self.font
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.lImageView)
        self.contentView.addSubview(self.tImageView)
        self.contentView.addSubview(self.rImageView)
        self.contentView.addSubview(self.bImageView)
        
        self.leftIcon.imageChangedCallback = {[unowned self] in
            self.update(isUpdateLayout: $0 == .normal)
        }
        self.leftIcon.imageSizeCallback = {[unowned self] in
            self.update(isUpdateAppearance: false, isUpdateLayout: true)
        }
        
        self.topIcon.imageChangedCallback = {[unowned self] in
            self.update(isUpdateLayout: $0 == .normal)
        }
        self.topIcon.imageSizeCallback = {[unowned self] in
            self.update(isUpdateAppearance: false, isUpdateLayout: true)
        }
        
        self.rightIcon.imageChangedCallback = {[unowned self] in
            self.update(isUpdateLayout: $0 == .normal)
        }
        self.rightIcon.imageSizeCallback = {[unowned self] in
            self.update(isUpdateAppearance: false, isUpdateLayout: true)
        }
        
        self.bottomIcon.imageChangedCallback = {[unowned self] in
            self.update(isUpdateLayout: $0 == .normal)
        }
        self.bottomIcon.imageSizeCallback = {[unowned self] in
            self.update(isUpdateAppearance: false, isUpdateLayout: true)
        }
        
        
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
                self?.updateAppearance()
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
    
    
    // MARK: - Update
    private func updateAppearance(isForce: Bool = false) {
        guard self.prevState != self.state || isForce else {
            return
        }
        if self.state != self.prevState {
            self.stateChangedCallback?(self.state)
        }
        
        self.prevState = self.state
        
        self.lImageView.image = self.leftIcon.getImage(state: self.state) ?? self.leftIcon.image
        self.tImageView.image = self.topIcon.getImage(state: self.state) ?? self.topIcon.image
        self.rImageView.image = self.rightIcon.getImage(state: self.state) ?? self.rightIcon.image
        self.bImageView.image = self.bottomIcon.getImage(state: self.state) ?? self.bottomIcon.image
        
        self.backgroundImageView.image = self.backgroundImageSet[self.state.rawValue] ?? self.backgroundImage
        
        if let attributedTitle = self.attributedTitleSet[self.state.rawValue] ?? self.attributedTitle {
            self.titleLabel.attributedText = attributedTitle
        } else {
            self.titleLabel.textColor = self.titleColorSet[self.state.rawValue] ?? self.titleColor
            
            let title = self.titleSet[self.state.rawValue] ?? self.title
            let isUpdate = self.titleLabel.text != title
            self.titleLabel.text = title
            
            if isUpdate {
                self.layoutContentView()
            }
        }
    }
    
    private func updateLayer() {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
    }
    
    private func update(isUpdateAppearance: Bool = true, isUpdateLayout: Bool = true) {
        self.updateAppearance(isForce: isUpdateAppearance)

        if isUpdateLayout {
            self.layoutContentView()
        }
    }
    
    // MARK: - Layout
    private func layoutContentView() {
        
        // - 设置Size
        var contentSize: CGSize = .zero
        
        self.titleLabel.sizeToFit()
        contentSize.width += self.titleLabel.frame.width
        contentSize.height += self.titleLabel.frame.height
        
        self.lImageView.bounds.size = .zero
        if let image = self.leftIcon.image {
            self.lImageView.bounds.size = self.leftIcon.imageSize ?? image.size
            
            contentSize.height = max(self.lImageView.bounds.height, contentSize.height)
            contentSize.width += self.lImageView.bounds.width + self.spaceingTitleImage
        }
        
        self.tImageView.bounds.size = .zero
        if let image = self.topIcon.image {
            self.tImageView.bounds.size = self.topIcon.imageSize ?? image.size
            
            contentSize.width = max(self.tImageView.bounds.width, contentSize.width)
            contentSize.height += self.tImageView.bounds.height + self.spaceingTitleImage
        }
        
        self.rImageView.bounds.size = .zero
        if let image = self.rightIcon.image {
            self.rImageView.bounds.size = self.rightIcon.imageSize ?? image.size
            
            contentSize.height = max(self.rImageView.bounds.height, contentSize.height)
            contentSize.width += self.rImageView.bounds.width + self.spaceingTitleImage
        }
        
        self.bImageView.bounds.size = .zero
        if let image = self.bottomIcon.image {
            self.bImageView.bounds.size = self.bottomIcon.imageSize ?? image.size
            
            contentSize.width = max(self.bImageView.bounds.width, contentSize.width)
            contentSize.height += self.bImageView.bounds.height + self.spaceingTitleImage
        }
        
        if contentSize.equalTo(.zero) && self.backgroundImageView.image != nil {
            contentSize = self.backgroundImageView.sizeThatFits(.zero)
        }
        
        
        // - 设置origin
        var titleOrigin = CGPoint.zero
        
        if self.leftIcon.image != nil && self.rightIcon.image != nil {
            titleOrigin.x = (contentSize.width - self.titleLabel.bounds.width) / 2
        } else if self.self.leftIcon.image != nil {
            titleOrigin.x = contentSize.width - self.titleLabel.bounds.width
        } else if self.self.rightIcon.image != nil {
            titleOrigin.x = 0
        } else {
            titleOrigin.x = (contentSize.width - self.titleLabel.bounds.width) / 2
        }
        
        if self.topIcon.image != nil && self.bottomIcon.image != nil {
            titleOrigin.y = (contentSize.height - self.titleLabel.bounds.height) / 2
        } else if self.topIcon.image != nil {
            titleOrigin.y = contentSize.height - self.titleLabel.bounds.height
        } else if self.bottomIcon.image != nil {
            titleOrigin.y = 0
        } else {
            titleOrigin.y = (contentSize.height - self.titleLabel.bounds.height) / 2
        }
        
        self.titleLabel.frame.origin = titleOrigin
        
        let titleRect = self.titleLabel.frame
        if self.leftIcon.image != nil {
            let rect = self.lImageView.frame
            let y = (contentSize.height - rect.height) / 2
            self.lImageView.frame.origin = .init(x: titleRect.minX - rect.width - self.spaceingTitleImage, y: y)
        }
        
        
        if self.rightIcon.image != nil {
            let rect = self.rImageView.frame
            let y = (contentSize.height - rect.height) / 2
            self.rImageView.frame.origin = .init(x: titleRect.maxX + self.spaceingTitleImage, y: y)
        }
        
        if self.topIcon.image != nil {
            let rect = self.tImageView.frame
            let x = (contentSize.width - rect.width) / 2
            self.tImageView.frame.origin = .init(x: x, y: titleRect.minY - rect.height - self.spaceingTitleImage)
        }
        
        if self.bottomIcon.image != nil {
            let rect = self.bImageView.frame
            let x = (contentSize.width - rect.width) / 2
            self.bImageView.frame.origin = .init(x: x, y: titleRect.maxY + self.spaceingTitleImage)
        }
        
        
        if !self.contentSize.equalTo(contentSize) {
            self.contentSize = contentSize
            self.contentView.frame.size = contentSize
            self.invalidateIntrinsicContentSize()
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
extension PKUIButton {
    
    public func setTitle(_ title: String?, state: UIControl.State) {
        if let title = title {
            self.titleSet[state.rawValue] = title
        } else {
            self.titleSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: state == .normal)
    }
    
    public func getTitle(_ state: UIControl.State) -> String? {
        return self.titleSet[state.rawValue]
    }
    
    public func setTitleColor(_ color: UIColor?, state: UIControl.State) {
        if let color = color {
            self.titleColorSet[state.rawValue] = color
        } else {
            self.titleColorSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: false)
    }
    
    public func getTitleColor(_ state: UIControl.State) -> UIColor? {
        return self.titleColorSet[state.rawValue]
    }
    
    public func setAttributedTitle(_ title: NSAttributedString?, state: UIControl.State) {
        if let title = title {
            self.attributedTitleSet[state.rawValue] = title
        } else {
            self.attributedTitleSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: state == .normal)
    }
    
    public func getAttributedTitle(_ state: UIControl.State) -> NSAttributedString? {
        return self.attributedTitleSet[state.rawValue]
    }
    
    public func setBackgroundImage(_ image: UIImage?, state: UIControl.State) {
        if let image = image {
            self.backgroundImageSet[state.rawValue] = image
        } else {
            self.backgroundImageSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: state == .normal)
    }
    
    public func getBackgroundImage(_ state: UIControl.State) -> UIImage? {
        return self.backgroundImageSet[state.rawValue]
    }
}


// MARK: - Icon
extension PKUIButton {
    
    open class Icon {
        
        var imageChangedCallback: ((_ state: UIControl.State) -> Void)?
        var imageSizeCallback: (() -> Void)?
        var imageSet = [UIControl.State.RawValue: UIImage]()
        
        open var image: UIImage? {
            set { self.setImage(newValue, state: .normal) }
            get { return self.getImage(state: .normal) }
        }
        
        open var imageSize: CGSize? {
            didSet {
                self.imageSizeCallback?()
            }
        }
        
        // MARK: - Public
        open func setImage(_ image: UIImage?, state: UIControl.State) {
            if let image = image {
                self.imageSet[state.rawValue] = image
            } else {
                self.imageSet.removeValue(forKey: state.rawValue)
            }
            self.imageChangedCallback?(state)
        }
        
        open func getImage(state: UIControl.State) -> UIImage? {
            return self.imageSet[state.rawValue]
        }
    }
}
