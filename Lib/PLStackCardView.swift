//
//  PLStackCardView.swift
//  PLKit
//
//  Created by iOS on 2019/7/15.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

@objc protocol PLStackCardViewDelegate {
    
    /// 卡片滑出
    /// - Parameters:
    ///   - stackCardView:
    ///   - card: 滑出的卡片
    ///   - direction: 滑出方向
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, willDismiss card: PLStackCardView.CardView, direction: PLStackCardView.Direction)
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, didDismiss card: PLStackCardView.CardView, direction: PLStackCardView.Direction)
    
    
    /// 卡片显示
    /// - Parameters:
    ///   - stackCardView:
    ///   - card: 当前卡片
    ///   - nextCard: 下一张卡片
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, willAppear card: PLStackCardView.CardView, nextCard: PLStackCardView.CardView?)
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, didAppear card: PLStackCardView.CardView, nextCard: PLStackCardView.CardView?)
    
    
    /// 卡片恢复原位 不执行操作
    /// - Parameters:
    ///   - stackCardView:
    ///   - card:
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, didRestore card: PLStackCardView.CardView)
    
    
    /// 卡片滑出进度
    /// - Parameters:
    ///   - stackCardView:
    ///   - progress: -1<-0->1 之间 大于0向右 小于0向左
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, didChangeProgress progress: CGFloat)
    
    /// 卡片是否可以滑出
    /// - Parameters:
    ///   - stackCardView:
    ///   - card:
    ///   - direction:
    @objc optional func stackCardView(_ stackCardView: PLStackCardView, canPop card: PLStackCardView.CardView, direction: PLStackCardView.Direction) -> Bool
}

class PLStackCardView: UIView {
    @objc enum Direction: Int {
        case left
        case right
    }
    
    weak var delegate: PLStackCardViewDelegate?
    
    /// 卡片大小
    private(set) var cardSize: CGSize = .zero
    
    /// 底部漏出几张
    private(set) var leakCount: Int = 1
    
    /// 底部漏出大小
    private(set) var leakSize: CGFloat = 20
    
    /// 底部卡片缩放率
    private(set) var scale: CGFloat = 0.9
    
    ///
    private(set) var cardViews = [CardView]()
    
    init(cardSize: CGSize, leakCount: Int = 1, leakSize: CGFloat = 20, scale: CGFloat = 0.9) {
        super.init(frame: .zero)
        
        self.cardSize = cardSize
        self.leakCount = leakCount
        self.leakSize = leakSize
        self.scale = scale
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureHandle(_:)))
        self.addGestureRecognizer(pan)
    }
    
    func setCardViews(_ views: [UIView]) {
        self.cardViews.forEach({ $0.removeFromSuperview() })
        
        self.cardViews = views.map({ CardView($0) })
        self.reloadData(self.cardViews)
        self.update()
        
        if let view = self.cardViews.first {
            self.delegate?.stackCardView?(self, didAppear: view, nextCard: self.nextCardView())
        }
    }
    
    func appendCardViews(_ views: [UIView]) {
        self.cardViews.append(contentsOf: views.map({ CardView($0) }))
        self.reloadData([CardView](self.cardViews[(self.cardViews.count - views.count)...]))
        self.update(start: self.cardViews.count - views.count)
        
        if self.cardViews.count - views.count <= 0, let view = self.cardViews.first {
            self.delegate?.stackCardView?(self, didAppear: view, nextCard: self.nextCardView())
        }
    }
    
    /// 重新加载卡片
    private func reloadData(_ views: [CardView]) {
        for view in views {
            view.frame = .init(x: 0, y: 0, width: self.cardSize.width, height: self.cardSize.height)
            self.addSubview(view)
            self.sendSubviewToBack(view)
        }
    }
    
    /// 更新所有的卡片布局
    private func update(start: Int = 0) {
        for i in start ..< self.cardViews.count {
            let card = self.cardViews[i]
            
            let s = self.getCardScale(i)
            var transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.getOffsetY(i))
            transform = transform.scaledBy(x: s, y: s)
            card.transform = transform
            
            card.alpha = i > self.leakCount ? 0 : 1
        }
    }
    
    private func getOffsetY(_ index: Int) -> CGFloat {
        let s = self.getCardScale(index)
        let offsetY = self.cardSize.height * (1 - s) / 2 + self.leakSize * CGFloat(index)
        return offsetY
    }
    
    private func getCardScale(_ index: Int) -> CGFloat {
        return pow(self.scale, CGFloat(index))
    }
    
    /// 弹出当前卡片
    /// - Parameter isRight: 弹出方向
    func pop(_ direction: Direction) {
        
        guard let card = self.cardViews.first else {
            return
        }
        
        self.cardViews.removeFirst()
        self.delegate?.stackCardView?(self, willDismiss: card, direction: direction)
        if let first = self.cardViews.first {
            self.delegate?.stackCardView?(self, willAppear: first, nextCard: self.nextCardView())
        }
        
        
        let progress: CGFloat = direction == .right ? 1 : -1
        let transform = CGAffineTransform.identity.rotated(by: .pi / 4 * progress)
        let point = self.calculateNextLinePoint(p1: card.center, p2: .init(x: card.center.x + card.frame.width * progress, y: card.center.y), distance: 1000)
        
        UIView.animateKeyframes(withDuration: 0.35, delay: 0, options: .init(rawValue: 0)) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                card.transform = transform
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                card.center = point
                self.update()
            }
        } completion: { (_) in
            card.removeFromSuperview()
            self.delegate?.stackCardView?(self, didDismiss: card, direction: direction)
            if let first = self.cardViews.first {
                self.delegate?.stackCardView?(self, didAppear: first, nextCard: self.nextCardView())
            }
        }
    }
    
    private func nextCardView() -> CardView? {
        return self.cardViews.count > 1 ? self.cardViews[1] : nil
    }
    
    override var intrinsicContentSize: CGSize {
        return self.sizeThatFits(.zero)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let totalHeight = self.cardSize.height + CGFloat(self.leakCount) * self.leakSize
        return .init(width: self.cardSize.width, height: totalHeight)
    }
    
    
    // MARK: - - Gesture
    private var panBeginPoint = CGPoint.zero
    private var panPrePoint = CGPoint.zero
    
    @objc private func panGestureHandle(_ sender: UIPanGestureRecognizer) {
        guard let card = self.cardViews.first else {
            return
        }
        
        guard bounds.width > 0 && bounds.height > 0 else {
            return
        }

        let point = sender.location(in: self)
        let progress = min(1, max(-1, (point.x - panBeginPoint.x) / (bounds.width / 2)))
        let rotateProgress = min(1, max(-1, (point.x - panBeginPoint.x) / (bounds.width / 1)))
        
        if sender.state == .began {
            self.panBeginPoint = point
        } else if sender.state == .changed {

            let x = point.x - panPrePoint.x
            
            card.transform = CGAffineTransform.identity.rotated(by: .pi / 4 * rotateProgress)
            card.center.x += x * 1.5
            self.interactiveUpdateBackCards(progress)
            
            self.delegate?.stackCardView?(self, didChangeProgress: progress)
            
        } else {
            
            let canPop = self.delegate?.stackCardView?(self, canPop: card, direction: progress > 0 ? .right : .left) ?? true
            let vel = sender.velocity(in: self)
            if canPop && (abs(progress) > 0.5 || abs(vel.x) >= 500) {
                self.pop(progress > 0 ? .right : .left)
            } else {
                self.delegate?.stackCardView?(self, didRestore: card)
                UIView.animate(withDuration: 0.25) {
                    card.transform = CGAffineTransform.identity
                    card.center = .init(x: card.bounds.width / 2, y: card.bounds.height / 2)
                    self.interactiveRestoreBackCards()
                }
            }
        }

        self.panPrePoint = point
    }
    
    
    /// 手势-更新第一张之后的卡片
    /// - Parameter progress:
    private func interactiveUpdateBackCards(_ progress: CGFloat) {
        if self.cardViews.count > 1 {
            let absp = abs(progress)
            for i in 1 ..< self.cardViews.count {
                let tc = self.cardViews[i]
                guard tc.alpha == 1 else {
                    break
                }
                let nextScale = self.getCardScale(i - 1)
                var scale = self.getCardScale(i)
                scale = (nextScale - scale) * absp + scale
                
                let nextOffsetY = self.getOffsetY(i - 1)
                var offsetY = self.getOffsetY(i)
                offsetY -= (offsetY - nextOffsetY) * absp
                var transform = CGAffineTransform.identity.translatedBy(x: 0, y: offsetY)
                transform = transform.scaledBy(x: scale, y: scale)
                tc.transform = transform
            }
        }
    }
    
    /// 手势-恢复卡片为原来的状态
    private func interactiveRestoreBackCards() {
        if self.cardViews.count > 1 {
            
            for i in 1 ..< self.cardViews.count {
                let tc = self.cardViews[i]
                guard tc.alpha == 1 else {
                    break
                }
                let scale = self.getCardScale(i)
                
                let offsetY = self.getOffsetY(i)
                var transform = CGAffineTransform.identity.translatedBy(x: 0, y: offsetY)
                transform = transform.scaledBy(x: scale, y: scale)
                tc.transform = transform
            }
        }
    }
    
    /// 计算一条直线的下一个点的位置
    /// - Parameters:
    ///   - p1:
    ///   - p2:
    ///   - distance: 与p1的距离
    /// - Returns:
    private func calculateNextLinePoint(p1: CGPoint, p2: CGPoint, distance: CGFloat) -> CGPoint {
        let l = sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2))
        if l == 0 {
            return .zero
        }

        var point = CGPoint.zero
        point.y = (distance * (p2.y - p1.y)) / l + p1.y
        point.x = (distance * (p2.x - p1.x)) / l + p1.x
        return point
    }
}

// MARK: - Class CardView
extension PLStackCardView {
    class CardView: UIView {
        
        var contentView: UIView!
        init(_ contentView: UIView) {
            super.init(frame: .zero)
            self.contentView = contentView
            self.addSubview(self.contentView)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.contentView.frame = self.bounds
        }
    }
}
