//
//  PKUIPopup.swift
//
//  Created by Plumk on 2019/4/23.
//  Copyright © 2019 Plumk. All rights reserved.
//


import UIKit


/// 弹窗 支持 Alert 和 Sheet 模式
/// 使用自动布局填充内容视图

open class PKUIPopup: UIView {
    
    public typealias DidCloseCallback = (PKUIPopup)->Void
    
    
    /// Alert弹窗 内容宽度
    open var alertContentWidth: CGFloat {
        return max(0, (PKUIWindowGetter.window?.frame.width ?? 0) - 60)
    }
    
    /// 优先级
    public var priority: Priority = .low
    
    /// 是否点击黑色区域关闭
    public var isTouchClose: Bool = true
    
    /// 关闭回调
    public var didCloseCallback: DidCloseCallback?
    
    /// 圆角
    public var contentRadius: CornerRadius = .init(radius: 24, corners: .allCorners)
    
    /// 附加在哪个view上
    public private(set) var attachView: UIView?
    
    /// 当前弹窗类型
    public private(set) var popupType: PopupType = .alert
    
    /// 内容view
    public private(set) var contentView: UIView!
    
    /// 当前是否显示中
    public private(set) var isShowing: Bool = false
    
    /// 当前归属于那一条弹窗链
    public private(set) weak var popupLink: PKUIPopupLink!
    
    /// 当前弹窗是否挂起中
    public private(set) var isSuspending: Bool = false
    
    /// 填充view 当sheet方式显示时候填充底部安全区域
    public private(set) var paddingView: UIView!
    
    /// 点击关闭Control
    private var touchCloseControl: UIControl!
    
    public init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    deinit {
        
    }
    
    /// 子类重写进行初始化
    open func setup() {
        self.popupLink = PKUIPopupLink.default
        
        self.touchCloseControl = UIControl()
        self.touchCloseControl.addTarget(self, action: #selector(touchCloseControlClick), for: .touchUpInside)
        self.addSubview(self.touchCloseControl)
        
        self.contentView = UIView()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.paddingView = UIView()
        self.paddingView.translatesAutoresizingMaskIntoConstraints = false
        self.paddingView.backgroundColor = .white
        self.paddingView.addSubview(self.contentView)
        
        self.addSubview(self.paddingView)
        
        
        
        
        _ = self.alert()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.touchCloseControl.frame = self.bounds
        
        self.paddingView.layer.cornerRadius = self.contentRadius.radius
        
        var corners: CACornerMask = .init(rawValue: 0)
        if self.contentRadius.corners.contains(.topLeft) {
            corners.insert(.layerMinXMinYCorner)
        }
        
        if self.contentRadius.corners.contains(.topRight) {
            corners.insert(.layerMaxXMinYCorner)
        }
        
        if self.contentRadius.corners.contains(.bottomLeft) {
            corners.insert(.layerMinXMaxYCorner)
        }
        
        if self.contentRadius.corners.contains(.bottomRight) {
            corners.insert(.layerMaxXMaxYCorner)
        }
        
        self.paddingView.layer.maskedCorners = corners
    }
    
    
    /// 点击关闭事件
    @objc private func touchCloseControlClick() {
        if self.isTouchClose {
            self.hide()
        }
    }
    
    /// 清空paddingView 和 contentview的约束
    private func removeChildConstraints() {
        
        var constraints = self.contentView.constraints
        for constraint in constraints {
            if let firstView = constraint.firstItem as? UIView, firstView == self.contentView {
                self.contentView.removeConstraint(constraint)
            }
        }
        
        self.paddingView.removeConstraints(self.paddingView.constraints)
        
        constraints = self.constraints
        for constraint in constraints {
            let firstView = constraint.firstItem as? UIView
            let secondView = constraint.secondItem as? UIView
            
            if firstView == self.paddingView || secondView == self.paddingView {
                self.removeConstraint(constraint)
            }
        }
    }
    
    // MARK: - 弹窗类型
    
    /// 以Alert方式显示
    /// - Returns:
    @discardableResult
    open func alert() -> Self {
        self.popupType = .alert
        self.contentRadius = .init(radius: 24, corners: .allCorners)
        
        self.removeChildConstraints()
        
        let bottom = self.contentView.bottomAnchor.constraint(equalTo: self.paddingView.bottomAnchor)
        bottom.priority = .defaultLow
        
        let right = self.contentView.rightAnchor.constraint(equalTo: self.paddingView.rightAnchor)
        right.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            self.contentView.leftAnchor.constraint(equalTo: self.paddingView.leftAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.paddingView.topAnchor),
            self.contentView.widthAnchor.constraint(equalToConstant: self.alertContentWidth),
            bottom, right
        ])

        NSLayoutConstraint.activate([
            self.paddingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.paddingView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        return self
    }
    
    /// 以Sheet方式显示
    /// - Returns:
    @discardableResult
    open func sheet() -> Self {
        self.popupType = .sheet
        self.contentRadius = .init(radius: 24, corners: [.topLeft, .topRight])
        
        self.removeChildConstraints()
        
        let bottom = self.contentView.bottomAnchor.constraint(equalTo: self.paddingView.safeAreaLayoutGuide.bottomAnchor)
        bottom.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            self.contentView.leftAnchor.constraint(equalTo: self.paddingView.leftAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.paddingView.topAnchor),
            self.contentView.rightAnchor.constraint(equalTo: self.paddingView.rightAnchor),
            bottom
        ])

        NSLayoutConstraint.activate([
            self.paddingView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.paddingView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        return self
    }
    
    // MARK: - Show & Hide
    
    /// 将要显示 子类设置数据
    open func willShow() {
        
    }
    
    open func didShow() {
        
    }
    
    /// 将要隐藏 子类设置数据
    open func willHide() {
        
    }
    
    open func didHide() {
        
    }
    
    @discardableResult
    open func show(in view: UIView? = PKUIWindowGetter.window, animate: Bool = true, complete: (() -> Void)? = nil) -> Self {
        guard self.isShowing == false,
            let view = view else {
            return self
        }
        
        PKUIWindowGetter.window?.endEditing(true)
        self.isShowing = true
        self.willShow()
        
        self.frame = view.bounds
        self.attachView = view
        view.addSubview(self)
        
        self.popupLink.push(self)
        
        // 当前优先级高没有被挂起 并且有动画才显示
        if !self.isSuspending && animate {
            self.layoutIfNeeded()
            self.execShowAnimation(complete: complete)
        } else {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.didShow()
            complete?()
        }
        
        return self
    }
    
    @discardableResult
    open func hide(animate: Bool = true) -> Self {
        guard self.isShowing else {
            return self
        }
        self.isShowing = false
        self.willHide()
        
        /// 当是最后一个时执行动画 否则直接移除
        if self.popupLink.isLast(self) {
            
            if animate {
                self.execHideAnimation()
            } else {
                self.didHide()
                self.removeFromSuperview()
            }
            
            self.popupLink.pop()
            
        } else {
            self.popupLink.remove(self)
            self.didHide()
            self.removeFromSuperview()
        }
        
        self.didCloseCallback?(self)
        return self
    }
    
    // MARK: - Animation
    
    /// 执行显示动画
    private func execShowAnimation(complete: (() -> Void)? = nil) {
        
        switch self.popupType {
        case .alert:
            self.backgroundColor = .clear
            self.paddingView.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
            
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: []) {
                self.paddingView.transform = .identity
            } completion: { _ in
                self.didShow()
                complete?()
            }
            
        case .sheet:
            
            self.backgroundColor = .clear
            self.paddingView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.paddingView.frame.height)
            
            UIView.animate(withDuration: 0.25) {
                self.paddingView.transform = .identity
                self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            } completion: { _ in
                self.didShow()
                complete?()
            }

        }
        
    }
    
    /// 执行隐藏动画
    private func execHideAnimation() {
        
        switch self.popupType {
        case .alert:
            UIView.animate(withDuration: 0.25) {
                self.alpha = 0
            } completion: { _ in
                self.didHide()
                self.removeFromSuperview()
            }
            
        case .sheet:
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = .clear
                self.paddingView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.paddingView.frame.height)
            } completion: { _ in
                self.didHide()
                self.removeFromSuperview()
            }
        }
    }
    
    
    // MARK: - 链式设置
    @discardableResult
    open func setIsTouchClose(_ isTouchClose: Bool) -> Self {
        self.isTouchClose = isTouchClose
        return self
    }
    
    @discardableResult
    open func setDidCloseCallback(_ callback: @escaping DidCloseCallback) -> Self {
        self.didCloseCallback = callback
        return self
    }
    
    @discardableResult
    open func setPopupLink(_ link: PKUIPopupLink) -> Self {
        self.popupLink = link
        return self
    }
    
    
    // MARK: - 挂起 & 恢复
    open func suspend(animate: Bool = true) {
        guard !self.isSuspending else {
            return
        }
        self.isSuspending = true
        
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.alpha = 0
            }
        } else {
            self.alpha = 0
        }
    }
    
    open func resumne() {
        guard self.isSuspending else {
            return
        }
        self.isSuspending = false
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}


// MARK: - Types

extension PKUIPopup {
    
    /// 弹窗类型
    public enum PopupType {
        case alert
        case sheet
    }
    
    /// 圆角设置
    public struct CornerRadius {
        public let radius: CGFloat
        public let corners: UIRectCorner
    }
    
    
    /// 优先级
    public struct Priority: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let low: Priority = .init(rawValue: 250)
        public static let middle: Priority = .init(rawValue: 500)
        public static let high: Priority = .init(rawValue: 750)
        public static let urgent: Priority = .init(rawValue: 1000)
    }
}
