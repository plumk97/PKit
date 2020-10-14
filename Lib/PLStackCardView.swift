//
//  PLStackCardView.swift
//  PLKit
//
//  Created by iOS on 2019/7/15.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

@objc protocol PLStackCardViewDelegate {
    @objc optional func stackCardView(_ cardView: PLStackCardView, didDismiss card: PLStackCardView.CardView)
    @objc optional func stackCardView(_ cardView: PLStackCardView, didAppear card: PLStackCardView.CardView, nextCard: PLStackCardView.CardView?)
}

class PLStackCardView: UIView {
    
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
            let view = self.cardViews[i]
            
            let s = pow(self.scale, CGFloat(i))
            var transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.cardSize.height * (1 - s) / 2 + self.leakSize * CGFloat(i))
            transform = transform.scaledBy(x: s, y: s)
            view.transform = transform
            
            view.alpha = i > self.leakCount ? 0 : 1
        }
    }
    
    /// 弹出当前卡片
    /// - Parameter isRight: 弹出方向
    func pop(isRight: Bool) {
        
        guard let card = self.cardViews.first else {
            return
        }
        
        self.cardViews.removeFirst()
        
        let progress: CGFloat = isRight ? 1 : -1
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
            
            self.delegate?.stackCardView?(self, didDismiss: card)
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
        guard let view = self.cardViews.first else {
            return
        }

        guard bounds.width > 0 && bounds.height > 0 else {
            return
        }

        let point = sender.location(in: self)
        let progress = min(1, max(-1, (point.x - panBeginPoint.x) / (bounds.width / 2)))
        
        if sender.state == .began {
            self.panBeginPoint = point
        } else if sender.state == .changed {

            let x = point.x - panPrePoint.x

            view.transform = CGAffineTransform.identity.rotated(by: .pi / 4 * progress)
            view.center.x += x * 2

        } else {
            let vel = sender.velocity(in: self)
            if abs(progress) > 0.5 || abs(vel.x) >= 500 {
                self.pop(isRight: progress > 0)
            } else {
                UIView.animate(withDuration: 0.25) {
                    view.transform = CGAffineTransform.identity
                    view.center = .init(x: view.bounds.width / 2, y: view.bounds.height / 2)
                }
            }
        }

        self.panPrePoint = point
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
