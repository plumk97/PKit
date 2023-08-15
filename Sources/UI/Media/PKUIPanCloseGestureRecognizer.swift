//
//  PKUIPanCloseGestureRecognizer.swift
//  PKit
//
//  Created by Plumk on 2023/8/15.
//

import UIKit

open class PKUIPanCloseGestureRecognizer: UIGestureRecognizer {

    private var beginPoint = CGPoint.zero
    private var point = CGPoint.zero
    private weak var firstTouch: UITouch?
    open  var isRunning = false
    
    
    open override func reset() {
        super.reset()
        
        self.firstTouch = nil
        self.isRunning = false
    }
    
    open override func location(in view: UIView?) -> CGPoint {
        return self.point
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.firstTouch == nil else {
            return
        }
        self.firstTouch = touches.first
        self.isRunning = false
        self.beginPoint = self.firstTouch?.location(in: self.view) ?? .zero
        self.point = self.beginPoint
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.firstTouch?.phase == .moved else {
            return
        }
        
        self.point = self.firstTouch?.location(in: self.view) ?? .zero
        if self.point.y - self.beginPoint.y > 20 ||  self.point.y - self.beginPoint.y < -20 {
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
        
        guard self.firstTouch?.phase == .ended else {
            return
        }
        
        self.point = self.firstTouch?.location(in: self.view) ?? .zero
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
        
        guard self.firstTouch?.phase == .cancelled else {
            return
        }
        
        self.point = self.firstTouch?.location(in: self.view) ?? .zero
        if self.state != .possible {
            self.state = .cancelled
        } else {
            touches.forEach({
                self.ignore($0, for: event)
            })
        }
    }
}
