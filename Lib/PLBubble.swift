//
//  PLBubble.swift
//  PLKit
//
//  Created by iOS on 2020/4/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class PLBubble: UIView {
    
    struct Arrow {
        var width: CGFloat = 7
        var height: CGFloat = 10
        var radius: CGFloat = 1
    }
    // 箭头配置
    var arrow = Arrow()
    
    // 背景填充
    var padding: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    // 距离附加view的间距
    var spacing: CGFloat = 5
    // 边框圆角
    var borderRadius: CGFloat = 10
    
    private var isShowing: Bool = false
    // 点击关闭control
    private var coverControl: UIControl!
    // 箭头位置
    private var arrowPoint: CGPoint = .zero
    
    // 绘制边框
    private(set) var shapeLayer: CAShapeLayer!
    // 显示内容
    private(set) var contentView: UIView?
    // 附加view
    private weak var attachView: UIView?
    
    convenience init(contentView: UIView) {
        self.init(frame: .zero)
        self.contentView = contentView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.fillColor = UIColor.white.cgColor
        self.shapeLayer.strokeColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        self.shapeLayer.shadowOpacity = 1
        self.shapeLayer.shadowOffset = .zero
        self.shapeLayer.shadowColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        self.shapeLayer.shadowRadius = 2
        self.layer.addSublayer(self.shapeLayer)
    }
    
    
    private func redraw() {
        guard let contentView = self.contentView else {
            return
        }
        
        guard let attachView = self.attachView else {
            return
        }
        
        guard let window = UIApplication.shared.delegate?.window! else {
            return
        }
        
        // 计算frame
        guard let attachFrame = attachView.superview?.convert(attachView.frame, to: window) else {
            return
        }
        
        var contentFrame = contentView.frame
        

        var frame = CGRect.zero
        frame.size = .init(width: contentFrame.width + padding.left + padding.right,
                           height: contentFrame.height + padding.top + padding.bottom)
        frame.size.height += arrow.height
        
        /// 获取方向 - 0上 1下
        var direction = 0
        if attachFrame.minY - frame.height - spacing < UIApplication.shared.statusBarFrame.height + 44 {
            direction = 1
        }
        
        /// 设置Y坐标
        if direction == 0 {
            frame.origin.y = attachFrame.minY - spacing - frame.height
        } else {
            frame.origin.y = attachFrame.maxY + spacing
        }
        
        /// 设置X坐标
        frame.origin.x = attachFrame.minX + (attachFrame.width - frame.width) / 2
        if frame.minX <= 0 {
            frame.origin.x = 10
        } else if frame.maxX - window.bounds.width >= 0 {
            frame.origin.x = window.bounds.width - frame.width - 10
        }
        
        
        /// 设置contentView frame
        contentFrame.origin.x = padding.left
        contentFrame.origin.y = padding.top + (direction == 0 ? 0 : arrow.height)
        contentView.frame = contentFrame
        
        self.frame = frame
        let x = attachFrame.minX - frame.minX + attachFrame.width / 2
        self.drawBubble(direction: direction, arrowX: x)
        
    }
    
    
    /// 绘制气泡
    /// - Parameters:
    ///   - direction: 0上 1下
    ///   - arrowX: 箭头x位置
    private func drawBubble(direction: Int, arrowX: CGFloat) {
        
        
        let path = UIBezierPath()
        let bounds = self.bounds
        
        
        let min: (x: CGFloat, y: CGFloat) = (CGFloat(0), CGFloat(direction == 0 ? 0 : arrow.height))
        let max: (x: CGFloat, y: CGFloat) = (CGFloat(bounds.width), CGFloat(min.y + bounds.height - arrow.height))
        
        if direction == 0 {
            self.arrowPoint = .init(x: arrowX, y: max.y + arrow.height)
            
            path.move(to: .init(x: min.x + borderRadius, y: min.y))
            
            // 上边
            path.addLine(to: .init(x: max.x - borderRadius, y: min.y))
            path.addQuadCurve(to: .init(x: max.x, y: min.y + borderRadius), controlPoint: .init(x: max.x, y: min.y))
            
            // 右边
            path.addLine(to: .init(x: max.x, y: max.y - borderRadius))
            path.addQuadCurve(to: .init(x: max.x - borderRadius, y: max.y), controlPoint: .init(x: max.x, y: max.y))
            
            // 下边
            path.addLine(to: .init(x: arrowX + arrow.width, y: max.y))
            
            // 三角形
            path.addLine(to: .init(x: arrowX + arrow.radius, y: max.y + arrow.height - arrow.radius))
            
            path.addQuadCurve(to: .init(x: arrowX - arrow.radius, y: max.y + arrow.height - arrow.radius),
                              controlPoint: self.arrowPoint)
            
            path.addLine(to: .init(x: arrowX - arrow.width, y: max.y))
            
            // --
            path.addLine(to: .init(x: min.x + borderRadius, y: max.y))
            path.addQuadCurve(to: .init(x: min.x, y: max.y - borderRadius), controlPoint: .init(x: min.x, y: max.y))
            
            // 左边
            path.addLine(to: .init(x: min.x, y: min.y + borderRadius))
            path.addQuadCurve(to: .init(x: min.x + borderRadius, y: min.y), controlPoint: .init(x: min.x, y: min.y))
            
        } else {
            self.arrowPoint = .init(x: arrowX, y: min.y - arrow.height)
            
            path.move(to: .init(x: min.x + borderRadius, y: min.y))
            path.addLine(to: .init(x: arrowX - arrow.width, y: min.y))
            
            // 上边
            
            // 三角形
            path.addLine(to: .init(x: arrowX - arrow.radius, y: min.y - arrow.height + arrow.radius))
            
            path.addQuadCurve(to: .init(x: arrowX + arrow.radius, y: min.y - arrow.height + arrow.radius),
                              controlPoint: self.arrowPoint)
            
            path.addLine(to: .init(x: arrowX + arrow.width, y: min.y))
            
            
            path.addLine(to: .init(x: max.x - borderRadius, y: min.y))
            path.addQuadCurve(to: .init(x: max.x, y: min.y + borderRadius), controlPoint: .init(x: max.x, y: min.y))
            
            // 右边
            path.addLine(to: .init(x: max.x, y: max.y - borderRadius))
            path.addQuadCurve(to: .init(x: max.x - borderRadius, y: max.y), controlPoint: .init(x: max.x, y: max.y))
            
            // 下边
            path.addLine(to: .init(x: min.x + borderRadius, y: max.y))
            path.addQuadCurve(to: .init(x: min.x, y: max.y - borderRadius), controlPoint: .init(x: min.x, y: max.y))
            
            // 左边
            path.addLine(to: .init(x: min.x, y: min.y + borderRadius))
            path.addQuadCurve(to: .init(x: min.x + borderRadius, y: min.y), controlPoint: .init(x: min.x, y: min.y))
        }

        
        self.shapeLayer.path = path.cgPath
    }
    
    func show(attach view: UIView, animation: Bool = true) {
        
        guard !self.isShowing else {
            return
        }
        
        guard let contentView = self.contentView else {
            return
        }
        
        guard let window = UIApplication.shared.delegate?.window! else {
            return
        }
        
        self.isShowing = true
        
        self.addSubview(contentView)
        self.attachView = view
        self.redraw()
        
        
        self.coverControl = UIControl.init(frame: window.bounds)
        self.coverControl.addTarget(self, action: #selector(coverControlClick), for: .touchUpInside)
        window.addSubview(self.coverControl)
        
        // 设置锚点确定缩放位置
        var anchorPoint = CGPoint.zero
        anchorPoint.x = self.arrowPoint.x / self.bounds.width
        anchorPoint.y = self.arrowPoint.y / self.bounds.height
        
        self.layer.anchorPoint = anchorPoint
        
        var transfrom = self.transform
        transfrom = transfrom.translatedBy(x: self.bounds.width * (anchorPoint.x - 0.5), y: self.bounds.height * (anchorPoint.y - 0.5))
        self.transform = transfrom.scaledBy(x: 0.01, y: 0.01)
        
        window.addSubview(self)
        
        if animation{
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .layoutSubviews, animations: {
                self.transform = transfrom
            }) { (_) in
                
            }
        } else {
            self.transform = transfrom
        }
        
    }
    
    @objc private func coverControlClick() {
        self.hide()
    }
    
    func hide(animation: Bool = true) {
        guard self.isShowing else {
            return
        }
        self.isShowing = false
        
        if animation {
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = self.transform.scaledBy(x: 0.01, y: 0.01)
            }) { (_) in
                self.coverControl.removeFromSuperview()
                self.removeFromSuperview()
            }
        } else {
            self.coverControl.removeFromSuperview()
            self.removeFromSuperview()
        }
        
    }
}
