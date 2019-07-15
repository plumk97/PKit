//
//  PLStackCardView.swift
//  PLKit
//
//  Created by iOS on 2019/7/15.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLStackCardView: UIView {
    
    private(set) var contentSize: CGSize = .zero
    private(set) var scale: CGFloat = 0
    
    var cardViews: [UIView]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureHandle(_:)))
        self.addGestureRecognizer(pan)
    }
    
    convenience init(contentSize: CGSize, scale: CGFloat = 0.97) {
        self.init(frame: .init(x: 0, y: 0, width: contentSize.width, height: contentSize.height + contentSize.height * (1 - scale)))
        
        self.contentSize = contentSize
        self.scale = scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reloadData() {
        guard let cardViews = self.cardViews else {
            return
        }
        
        for (idx, view) in cardViews.enumerated().reversed() {
            view.frame.origin.y = 0
            if idx > 0 {
                var transform = CGAffineTransform.identity.scaledBy(x: self.scale, y: self.scale)
                transform = transform.translatedBy(x: 0, y: self.contentSize.height * (1 - self.scale) * 1.5)
                view.transform = transform
            }
            self.addSubview(view)
        }
    }
    
    
    private var panBeginPoint = CGPoint.zero
    private var panPrePoint = CGPoint.zero
    
    @objc func panGestureHandle(_ sender: UIPanGestureRecognizer) {
        guard let view = self.cardViews?.first else {
            return
        }
        
        let point = sender.location(in: self)
        let progress = min(1, (point.x - panBeginPoint.x) / (bounds.width / 2))
        
        if sender.state == .began {
            self.panBeginPoint = point
        } else if sender.state == .changed {
            
            let x = point.x - panPrePoint.x
            let y = point.y - panPrePoint.y
            
            view.transform = CGAffineTransform.identity.rotated(by: .pi / 4 * progress)
            
            view.center.x += x * 1.5
            view.center.y += y * 1.5
            
        } else {
            
            if abs(progress) > 0.5 {
                
                let point = self.linePoint(point1: self.panBeginPoint, point2: point, distance: 1000)
                self.cardViews?.removeFirst()
                UIView.animate(withDuration: 0.25, animations: {
                    view.center = point
                    self.cardViews?.first?.transform = .identity
                }) { (_) in
                    view.removeFromSuperview()
                }
                
            } else {
                UIView.animate(withDuration: 0.25) {
                    view.transform = CGAffineTransform.identity
                    view.center = .init(x: view.bounds.width / 2, y: view.bounds.height / 2)
                }
            }
        }
        
        self.panPrePoint = point
    }
    
    func linePoint(point1: CGPoint, point2: CGPoint, distance: CGFloat) -> CGPoint {
        
        let l = sqrt(pow((point1.x - point2.x), 2) + pow((point1.y - point2.y), 2))
        
        var point = CGPoint.zero
        point.y = (distance * (point2.y - point1.y)) / l + point1.y
        point.x = (distance * (point2.x - point1.x)) / l + point1.x
        
        return point
    }
}
