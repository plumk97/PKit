//
//  PKUIBubble.swift
//  PKit
//
//  Created by Plumk on 2020/4/2.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

open class PKUIBubble: UIView {
    
    
    /// 弹出方向
    public enum PopupDirection {
        
        case TL
        case T
        case TR
        
        case BL
        case B
        case BR
        
        case RT
        case R
        case RB
        
        case LT
        case L
        case LB
        
        
        var isVertical: Bool {
            return (
                self == .TL || self == .T || self == .TR ||
                self == .BL || self == .B || self == .BR
            )
        }
        
        var isHorizontal: Bool {
            return !self.isVertical
        }
        
        var isBottom: Bool {
            return self == .BL || self == .B || self == .BR
        }
        
        var isRight: Bool {
            return self == .RT || self == .R || self == .RB
        }
    }
    
    open var popupDirection = PopupDirection.T
    
    public struct Arrow {
        var width: CGFloat = 7
        var height: CGFloat = 10
        var radius: CGFloat = 1
    }
    
    // 箭头配置
    open var arrow = Arrow()
    // 偏移 水平则为x偏移 垂直则为y偏移
    open var offset: CGFloat = 0
    // 背景填充
    open var padding: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    // 距离附加view的间距
    open var spacing: CGFloat = 5
    // 边框圆角
    open var borderRadius: CGFloat = 10
    
    // 遮罩颜色
    open var coverColor: UIColor = .clear
    
    /// shapeLayer.fillColor
    open var fillColor: UIColor = .white {
        didSet {
            self.updateShapeLayerColor()
        }
    }
    
    /// shapeLayer.strokeColor
    open var strokeColor: UIColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1) {
        didSet {
            self.updateShapeLayerColor()
        }
    }
    
    /// shapeLayer.shadowColor
    open var shadowColor: UIColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1) {
        didSet {
            self.updateShapeLayerColor()
        }
    }
    
    private var isShowing: Bool = false
    // 点击关闭control
    private var coverControl: UIControl!
    // 箭头位置
    private var arrowPoint: CGPoint = .zero
    
    // 绘制边框
    open private(set) var shapeLayer: CAShapeLayer!
    // 显示内容
    open private(set) var contentView: UIView?
    // 附加view
    private weak var attachView: UIView?
    // 显示到哪个view
    private weak var inView: UIView?
    
    public convenience init(contentView: UIView) {
        self.init(frame: .zero)
        self.contentView = contentView
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.shadowOpacity = 1
        self.shapeLayer.shadowOffset = .zero
        self.shapeLayer.shadowRadius = 2
        self.layer.addSublayer(self.shapeLayer)
        
        self.updateShapeLayerColor()
    }
    
    private func updateShapeLayerColor() {
        
        self.shapeLayer.fillColor = self.fillColor.cgColor
        self.shapeLayer.strokeColor = self.strokeColor.cgColor
        self.shapeLayer.shadowColor = self.shadowColor.cgColor
    }
    
    private func redraw() {
        guard let contentView = self.contentView else {
            return
        }
        
        guard let attachView = self.attachView else {
            return
        }
        
        guard let inView = self.inView else {
            return
        }
        
        // 计算frame
        guard let attachFrame = attachView.superview?.convert(attachView.frame, to: inView) else {
            return
        }
        
        var contentFrame = contentView.frame
        

        var frame = CGRect.zero
        frame.size = .init(width: contentFrame.width + padding.left + padding.right,
                           height: contentFrame.height + padding.top + padding.bottom)
        
        
        
        let direction = self.popupDirection
        
        if direction.isVertical {
            frame.size.height += arrow.height
        }  else {
            frame.size.width += arrow.height
        }
        
        /// 设置坐标
        switch direction {
        case .TL, .T, .TR:
            frame.origin.y = attachFrame.minY - spacing - frame.height
        case .BL, .B, .BR:
            frame.origin.y = attachFrame.maxY + spacing
        
        case .LT, .L, .LB:
            frame.origin.x = attachFrame.minX - spacing - frame.width
        case .RT, .R, .RB:
            frame.origin.x = attachFrame.maxX + spacing
        }
        
       
        var bubbleDrawPoint: CGFloat = 0
        if direction.isVertical {

            // 垂直方向 计算x坐标
            switch direction {
            case .TL, .BL:
                frame.origin.x = attachFrame.minX - borderRadius / 2
            case .T, .B:
                frame.origin.x = attachFrame.midX - frame.width / 2
            case .TR, .BR:
                frame.origin.x = attachFrame.maxX - frame.width + borderRadius / 2
            default:
                break
            }
            frame.origin.x += offset
            // 计算contentFrame
            contentFrame.origin.x = padding.left
            contentFrame.origin.y = padding.top + (direction.isBottom ? arrow.height : 0)
            
            // 气泡x中心点
            bubbleDrawPoint = attachFrame.minX - frame.minX + attachFrame.width / 2
            
        } else if direction.isHorizontal {
            
            // 水平方向 计算y坐标
            switch direction {
            case .LT, .RT:
                frame.origin.y = attachFrame.minY - borderRadius / 2
            case .L, .R:
                frame.origin.y = attachFrame.midY - frame.height / 2
            case .LB, .RB:
                frame.origin.y = attachFrame.maxY - frame.height + borderRadius / 2
            default:
                break
            }
            frame.origin.y += offset
            
            // 计算contentFrame
            contentFrame.origin.x = padding.left + (direction.isRight ? arrow.height : 0)
            contentFrame.origin.y = padding.top
            
            // 气泡y中心点
            bubbleDrawPoint = attachFrame.minY - frame.minY + attachFrame.height / 2
        }
        
        
        // 设置frame 和 绘画气泡
        contentView.frame = contentFrame
        self.frame = frame
        self.drawBubble(direction: direction, mid: bubbleDrawPoint)
    }
    
    
    /// 绘制气泡
    /// - Parameters:
    ///   - direction: 0上 1下
    ///   - mid: 箭头位置  垂直则为x 水平则为y
    private func drawBubble(direction: PopupDirection, mid: CGFloat) {
        
        
        let bounds = self.bounds
        let path = UIBezierPath()
        

        switch direction {
        case .TL, .T, .TR:
            let min: (x: CGFloat, y: CGFloat) = (CGFloat(0), CGFloat(0))
            let max: (x: CGFloat, y: CGFloat) = (CGFloat(bounds.width), CGFloat(min.y + bounds.height - arrow.height))
            
            self.arrowPoint = .init(x: mid, y: max.y + arrow.height)

            path.move(to: .init(x: min.x + borderRadius, y: min.y))

            PKUIBubble.Draw.topSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.rightSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.bottomArrow(path: path, min: min, max: max, radius: borderRadius, arrow: arrow, arrowPoint: arrowPoint)
            PKUIBubble.Draw.leftSide(path: path, min: min, max: max, radius: borderRadius)
            
            
        case .BL, .B, .BR:
            let min: (x: CGFloat, y: CGFloat) = (CGFloat(0), CGFloat(arrow.height))
            let max: (x: CGFloat, y: CGFloat) = (CGFloat(bounds.width), CGFloat(min.y + bounds.height - arrow.height))
            
            self.arrowPoint = .init(x: mid, y: min.y - arrow.height)

            path.move(to: .init(x: min.x + borderRadius, y: min.y))
            
            PKUIBubble.Draw.topArrow(path: path, min: min, max: max, radius: borderRadius, arrow: arrow, arrowPoint: arrowPoint)
            PKUIBubble.Draw.rightSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.bottomSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.leftSide(path: path, min: min, max: max, radius: borderRadius)
    
        case .LT, .L, .LB:
            let min: (x: CGFloat, y: CGFloat) = (CGFloat(0), CGFloat(0))
            let max: (x: CGFloat, y: CGFloat) = (CGFloat(min.x + bounds.width - arrow.height), CGFloat(bounds.height))
            
            self.arrowPoint = .init(x: max.x + arrow.height, y: mid)
            
            path.move(to: .init(x: min.x + borderRadius, y: min.y))
            
            PKUIBubble.Draw.topSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.rightArrow(path: path, min: min, max: max, radius: borderRadius, arrow: arrow, arrowPoint: arrowPoint)
            PKUIBubble.Draw.bottomSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.leftSide(path: path, min: min, max: max, radius: borderRadius)
            
        case .RT, .R, .RB:
            let min: (x: CGFloat, y: CGFloat) = (CGFloat(arrow.height), CGFloat(0))
            let max: (x: CGFloat, y: CGFloat) = (CGFloat(min.x + bounds.width - arrow.height), CGFloat(bounds.height))
            
            self.arrowPoint = .init(x: min.x - arrow.height, y: mid)
            
            path.move(to: .init(x: min.x + borderRadius, y: min.y))
            
            PKUIBubble.Draw.topSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.rightSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.bottomSide(path: path, min: min, max: max, radius: borderRadius)
            PKUIBubble.Draw.leftArrow(path: path, min: min, max: max, radius: borderRadius, arrow: arrow, arrowPoint: arrowPoint)

        }


        self.shapeLayer.path = path.cgPath
    }
    
    /// 显示
    /// - Parameters:
    ///   - view: 附加到哪个view
    ///   - inView: 显示到哪个view 为nil则显示到window
    ///   - touchClose: 是否可以点击关闭
    ///   - animation: 是否使用动画
    open func show(attach view: UIView?, in inView: UIView? = nil, touchClose: Bool = true, animation: Bool = true) {
        
        guard !self.isShowing else {
            return
        }
        
        guard view != nil else {
            return
        }
        
        guard let contentView = self.contentView else {
            return
        }
        
        self.inView = inView ?? PKUIWindowGetter.keyWindow
        guard let inView = self.inView else {
            return
        }
        
        self.isShowing = true
        
        self.addSubview(contentView)
        self.attachView = view
        self.redraw()
        
        
        guard !self.frame.size.equalTo(.zero) else {
            return
        }
        
        
        self.coverControl = UIControl.init(frame: inView.bounds)
        self.coverControl.isUserInteractionEnabled = touchClose
        self.bindHide(with: self.coverControl)
        inView.addSubview(self.coverControl)
        
        // 设置锚点确定缩放位置
        var anchorPoint = CGPoint.zero
        anchorPoint.x = self.arrowPoint.x / self.bounds.width
        anchorPoint.y = self.arrowPoint.y / self.bounds.height
        
        self.layer.anchorPoint = anchorPoint
        
        self.frame.origin = .init(x: self.frame.minX + self.frame.width * (anchorPoint.x - 0.5),
                                  y: self.frame.minY + self.frame.height * (anchorPoint.y - 0.5))
        
        let transfrom = self.transform
        self.transform = transfrom.scaledBy(x: 0.1, y: 0.1)
        
        inView.addSubview(self)
        
        if animation {
            self.coverControl.backgroundColor = .clear
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .layoutSubviews, animations: {
                self.coverControl.backgroundColor = self.coverColor
                self.transform = transfrom
            }) { (_) in
                
            }
        } else {
            self.coverControl.backgroundColor = self.coverColor
            self.transform = transfrom
        }
        
    }
    
    /// 重新定位当前位置
    /// - Parameter view:
    open func relocation() {
        
        guard self.isShowing else {
            return
        }
        
        self.redraw()
    }
    
    /// 隐藏
    /// - Parameter animation:
    open func hide(animation: Bool = true) {
        guard self.isShowing else {
            return
        }
        self.isShowing = false
        
        if animation {
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = self.transform.scaledBy(x: 0.01, y: 0.01)
            }) { (_) in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Bind
    /// 点击关闭
    @objc private func bindButtonClick() {
        self.hide()
    }
    
    /// 绑定按钮点击关闭
    /// - Parameter button:
    open func bindHide(with button: UIControl...) {
        self.bindHide(with: button)
    }
    
    open func bindHide(with buttons: [UIControl]) {
        buttons.forEach({
            $0.addTarget(self, action: #selector(bindButtonClick), for: .touchUpInside)
        })
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        self.coverControl.removeFromSuperview()
    }
    
    open override var isHidden: Bool {
        didSet {
            self.coverControl.isHidden = isHidden
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateShapeLayerColor()
    }
}


// MARK: - Draw
extension PKUIBubble {
    public struct Draw {
        
        // side
        public static func topSide(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat) {
            
            path.addLine(to: .init(x: max.x - radius, y: min.y))
            path.addQuadCurve(to: .init(x: max.x, y: min.y + radius), controlPoint: .init(x: max.x, y: min.y))
        }
        
        public static func rightSide(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat) {
            
            path.addLine(to: .init(x: max.x, y: max.y - radius))
            path.addQuadCurve(to: .init(x: max.x - radius, y: max.y), controlPoint: .init(x: max.x, y: max.y))
        }
        
        public static func bottomSide(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat) {
            
            path.addLine(to: .init(x: min.x + radius, y: max.y))
            path.addQuadCurve(to: .init(x: min.x, y: max.y - radius), controlPoint: .init(x: min.x, y: max.y))
        }
        
        public static func leftSide(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat) {
            
            path.addLine(to: .init(x: min.x, y: min.y + radius))
            path.addQuadCurve(to: .init(x: min.x + radius, y: min.y), controlPoint: .init(x: min.x, y: min.y))
        }
        
        
        // arrow
        public static func bottomArrow(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat, arrow: Arrow, arrowPoint: CGPoint) {
            
            
            path.addLine(to: .init(x: arrowPoint.x + arrow.width, y: max.y))
            
            // -- arrow begin
            path.addLine(to: .init(x: arrowPoint.x + arrow.radius, y: max.y + arrow.height - arrow.radius))
            
            path.addQuadCurve(to: .init(x: arrowPoint.x - arrow.radius, y: max.y + arrow.height - arrow.radius),
                              controlPoint: arrowPoint)
            
            path.addLine(to: .init(x: arrowPoint.x - arrow.width, y: max.y))
            // -- arrow end
            
            path.addLine(to: .init(x: min.x + radius, y: max.y))
            
            path.addQuadCurve(to: .init(x: min.x, y: max.y - radius), controlPoint: .init(x: min.x, y: max.y))
            
        }
        
        public static func topArrow(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat, arrow: Arrow, arrowPoint: CGPoint) {
            
            path.addLine(to: .init(x: arrowPoint.x - arrow.width, y: min.y))
            
            // -- arrow begin
            path.addLine(to: .init(x: arrowPoint.x - arrow.radius, y: min.y - arrow.height + arrow.radius))

            path.addQuadCurve(to: .init(x: arrowPoint.x + arrow.radius, y: min.y - arrow.height + arrow.radius),
                              controlPoint: arrowPoint)

            path.addLine(to: .init(x: arrowPoint.x + arrow.width, y: min.y))
            // -- arrow end
            
            path.addLine(to: .init(x: max.x - radius, y: min.y))
            path.addQuadCurve(to: .init(x: max.x, y: min.y + radius), controlPoint: .init(x: max.x, y: min.y))
            
        }
        
        public static func rightArrow(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat, arrow: Arrow, arrowPoint: CGPoint) {
            
            path.addLine(to: .init(x: max.x, y: arrowPoint.y - arrow.width))
            
            // -- arrow begin
            path.addLine(to: .init(x: max.x + arrow.height - arrow.radius, y: arrowPoint.y - arrow.radius))

            path.addQuadCurve(to: .init(x: max.x + arrow.height - arrow.radius, y: arrowPoint.y + arrow.radius),
                              controlPoint: arrowPoint)

            path.addLine(to: .init(x: max.x, y: arrowPoint.y + arrow.width))
            // -- arrow end
            
            path.addLine(to: .init(x: max.x, y: max.y - radius))
            path.addQuadCurve(to: .init(x: max.x - radius, y: max.y), controlPoint: .init(x: max.x, y: max.y))
            
        }
        
        public static func leftArrow(path: UIBezierPath, min: (x: CGFloat, y: CGFloat), max: (x: CGFloat, y: CGFloat), radius: CGFloat, arrow: Arrow, arrowPoint: CGPoint) {
            
            path.addLine(to: .init(x: min.x, y: arrowPoint.y + arrow.width))
            
            // -- arrow begin
            path.addLine(to: .init(x: min.x - arrow.height + arrow.radius, y: arrowPoint.y + arrow.radius))

            path.addQuadCurve(to: .init(x: min.x - arrow.height + arrow.radius, y: arrowPoint.y - arrow.radius),
                              controlPoint: arrowPoint)

            path.addLine(to: .init(x: min.x, y: arrowPoint.y - arrow.width))
            // -- arrow end
            
            path.addLine(to: .init(x: min.x, y: min.y + radius))
            path.addQuadCurve(to: .init(x: min.x + radius, y: min.y), controlPoint: .init(x: min.x, y: min.y))
            
        }
    }
}

