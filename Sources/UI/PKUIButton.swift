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
        set { self.setTitle(newValue, for: .normal) }
        get { self.getTitle(for: .normal) }
    }
    
    open var attributedTitle: NSAttributedString? {
        set { self.setAttributedTitle(newValue, for: .normal) }
        get { self.getAttributedTitle(for: .normal) }
    }
    
    open var titleColor: UIColor? {
        set { self.setTitleColor(newValue, for: .normal) }
        get { self.getTitleColor(for: .normal) }
    }
    
    open var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            self.titleLabel.font = self.font
            self.update(isUpdateAppearance: false)
        }
    }
    
    open var backgroundImage: UIImage? {
        set { self.setBackgroundImage(newValue, for: .normal) }
        get { self.getBackgroundImage(for: .normal) }
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
    
    private func getCurrentMainState() -> UIControl.State {
        if !self.isEnabled {
            return .disabled
        } else if self.isSelected {
            return .selected
        } else {
            return .normal
        }
    }
    
    // MARK: - Update
    private func updateAppearance(isForce: Bool = false) {
        guard self.prevState != self.state || isForce else {
            return
        }
        if self.state != self.prevState {
            self.stateChangedCallback?(self.state)
        }
        
        var isUpdate = false
        self.prevState = self.state
        
        let mainState = self.getCurrentMainState()
        
        /// - 更新左边的图标
        let limage = self.leftIcon.getImage(for: self.state) ?? self.leftIcon.getImage(for: mainState) ?? self.leftIcon.image
        if self.lImageView.image != limage {
            isUpdate = true
            self.lImageView.image = limage
        }
        
        /// - 更新上边的图标
        let timage = self.topIcon.getImage(for: self.state) ?? self.topIcon.getImage(for: mainState) ?? self.topIcon.image
        if self.tImageView.image != timage {
            isUpdate = true
            self.tImageView.image = timage
        }
        
        /// - 更新右边的图标
        let rimage = self.rightIcon.getImage(for: self.state) ?? self.rightIcon.getImage(for: mainState) ?? self.rightIcon.image
        if self.rImageView.image != rimage {
            isUpdate = true
            self.rImageView.image = rimage
        }
        
        /// - 更新下边的图标
        let bimage = self.bottomIcon.getImage(for: self.state) ?? self.bottomIcon.getImage(for: mainState) ?? self.bottomIcon.image
        if self.bImageView.image != bimage {
            isUpdate = true
            self.bImageView.image = bimage
        }
        
        
        /// - 更新背景图
        let backgroundImage = self.backgroundImageSet[self.state.rawValue] ?? self.backgroundImageSet[mainState.rawValue] ?? self.backgroundImage
        if self.backgroundImageView.image != backgroundImage {
            if self.contentView.bounds.size.equalTo(.zero) {
                /// - 如果内部没有内容则使用背景图填充
                isUpdate = true
            }
            self.backgroundImageView.image = backgroundImage
        }
        
        
        /// - 更新标题
        if let attributedTitle = self.attributedTitleSet[self.state.rawValue] ?? self.attributedTitleSet[mainState.rawValue] ?? self.attributedTitle {
            /// 富文本
            if self.titleLabel.attributedText != attributedTitle {
                isUpdate = true
                self.titleLabel.attributedText = attributedTitle
            }
            
        } else {
            /// 普通标题
            self.titleLabel.textColor = self.titleColorSet[self.state.rawValue] ?? self.titleColorSet[mainState.rawValue] ?? self.titleColor
            
            let title = self.titleSet[self.state.rawValue] ?? self.titleSet[mainState.rawValue] ?? self.title
            if self.titleLabel.text != title {
                isUpdate = true
                self.titleLabel.text = title
            }
        }
        
        if isUpdate && !isForce {
            self.layoutContentView()
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
        if let image = self.lImageView.image {
            self.lImageView.bounds.size = self.leftIcon.imageSize ?? image.size
            
            contentSize.height = max(self.lImageView.bounds.height, contentSize.height)
            contentSize.width += self.lImageView.bounds.width + self.spaceingTitleImage
        }
        
        self.tImageView.bounds.size = .zero
        if let image = self.tImageView.image {
            self.tImageView.bounds.size = self.topIcon.imageSize ?? image.size
            
            contentSize.width = max(self.tImageView.bounds.width, contentSize.width)
            contentSize.height += self.tImageView.bounds.height + self.spaceingTitleImage
        }
        
        self.rImageView.bounds.size = .zero
        if let image = self.rImageView.image {
            self.rImageView.bounds.size = self.rightIcon.imageSize ?? image.size
            
            contentSize.height = max(self.rImageView.bounds.height, contentSize.height)
            contentSize.width += self.rImageView.bounds.width + self.spaceingTitleImage
        }
        
        self.bImageView.bounds.size = .zero
        if let image = self.bImageView.image {
            self.bImageView.bounds.size = self.bottomIcon.imageSize ?? image.size
            
            contentSize.width = max(self.bImageView.bounds.width, contentSize.width)
            contentSize.height += self.bImageView.bounds.height + self.spaceingTitleImage
        }
        
        if contentSize.equalTo(.zero) && self.backgroundImageView.image != nil {
            contentSize = self.backgroundImageView.sizeThatFits(.zero)
        }
        
        
        // - 设置origin
        var titleOrigin = CGPoint.zero
        
        if self.lImageView.image != nil && self.rImageView.image != nil {
            titleOrigin.x = (contentSize.width - self.titleLabel.bounds.width) / 2
        } else if self.self.lImageView.image != nil {
            titleOrigin.x = contentSize.width - self.titleLabel.bounds.width
        } else if self.self.rImageView.image != nil {
            titleOrigin.x = 0
        } else {
            titleOrigin.x = (contentSize.width - self.titleLabel.bounds.width) / 2
        }
        
        if self.tImageView.image != nil && self.bImageView.image != nil {
            titleOrigin.y = (contentSize.height - self.titleLabel.bounds.height) / 2
        } else if self.tImageView.image != nil {
            titleOrigin.y = contentSize.height - self.titleLabel.bounds.height
        } else if self.bImageView.image != nil {
            titleOrigin.y = 0
        } else {
            titleOrigin.y = (contentSize.height - self.titleLabel.bounds.height) / 2
        }
        
        self.titleLabel.frame.origin = titleOrigin
        
        let titleRect = self.titleLabel.frame
        if self.lImageView.image != nil {
            let rect = self.lImageView.frame
            let y = (contentSize.height - rect.height) / 2
            self.lImageView.frame.origin = .init(x: titleRect.minX - rect.width - self.spaceingTitleImage, y: y)
        }
        
        
        if self.rImageView.image != nil {
            let rect = self.rImageView.frame
            let y = (contentSize.height - rect.height) / 2
            self.rImageView.frame.origin = .init(x: titleRect.maxX + self.spaceingTitleImage, y: y)
        }
        
        if self.tImageView.image != nil {
            let rect = self.tImageView.frame
            let x = (contentSize.width - rect.width) / 2
            self.tImageView.frame.origin = .init(x: x, y: titleRect.minY - rect.height - self.spaceingTitleImage)
        }
        
        if self.bImageView.image != nil {
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
    
    public func setTitle(_ title: String?, for state: UIControl.State) {
        if let title = title {
            self.titleSet[state.rawValue] = title
        } else {
            self.titleSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: state == .normal)
    }
    
    public func getTitle(for state: UIControl.State) -> String? {
        return self.titleSet[state.rawValue]
    }
    
    public func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        if let color = color {
            self.titleColorSet[state.rawValue] = color
        } else {
            self.titleColorSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: false)
    }
    
    public func getTitleColor(for state: UIControl.State) -> UIColor? {
        return self.titleColorSet[state.rawValue]
    }
    
    public func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        if let title = title {
            self.attributedTitleSet[state.rawValue] = title
        } else {
            self.attributedTitleSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: state == .normal)
    }
    
    public func getAttributedTitle(for state: UIControl.State) -> NSAttributedString? {
        return self.attributedTitleSet[state.rawValue]
    }
    
    public func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        if let image = image {
            self.backgroundImageSet[state.rawValue] = image
        } else {
            self.backgroundImageSet.removeValue(forKey: state.rawValue)
        }
        self.update(isUpdateLayout: state == .normal)
    }
    
    public func getBackgroundImage(for state: UIControl.State) -> UIImage? {
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
            set { self.setImage(newValue, for: .normal) }
            get { return self.getImage(for: .normal) }
        }
        
        open var imageSize: CGSize? {
            didSet {
                self.imageSizeCallback?()
            }
        }
        
        // MARK: - Public
        open func setImage(_ image: UIImage?, for state: UIControl.State) {
            if let image = image {
                self.imageSet[state.rawValue] = image
            } else {
                self.imageSet.removeValue(forKey: state.rawValue)
            }
            self.imageChangedCallback?(state)
        }
        
        open func getImage(for state: UIControl.State) -> UIImage? {
            return self.imageSet[state.rawValue]
        }
    }
}
