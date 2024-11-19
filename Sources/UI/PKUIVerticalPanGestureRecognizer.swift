//
//  PKUIVerticalPanGestureRecognizer.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import UIKit

open class PKUIVerticalPanGestureRecognizer: UIGestureRecognizer {
    
    private var beginPoint = CGPoint.zero
    private var point = CGPoint.zero
    private weak var touch: UITouch?
    
    public private(set) var isRunning = false
    
    public var threshold: CGFloat = 20
    
    open override func reset() {
        super.reset()
        
        self.touch = nil
        self.isRunning = false
    }
    
    open override func location(in view: UIView?) -> CGPoint {
        return self.point
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.touch == nil else {
            return
        }
        
        self.touch = touches.first
        self.isRunning = false
        self.beginPoint = self.touch?.location(in: self.view) ?? .zero
        self.point = self.beginPoint
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.touch?.phase == .moved else {
            return
        }
        
        self.point = self.touch?.location(in: self.view) ?? .zero
        if abs(self.point.y - self.beginPoint.y) > self.threshold {
            if self.state != .began {
                self.state = .began
                self.isRunning = true
            } else {
                self.state = .changed
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        defer {
            self.reset()
        }
        
        guard self.touch?.phase == .ended else {
            return
        }
        
        self.point = self.touch?.location(in: self.view) ?? .zero
        if self.state != .possible {
            self.state = .ended
        } else {
            touches.forEach({
                self.ignore($0, for: event)
            })
        }
    }
    
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        defer {
            self.reset()
        }
        
        guard self.touch?.phase == .cancelled else {
            return
        }
        
        self.point = self.touch?.location(in: self.view) ?? .zero
        if self.state != .possible {
            self.state = .cancelled
        } else {
            touches.forEach({
                self.ignore($0, for: event)
            })
        }
    }
}
