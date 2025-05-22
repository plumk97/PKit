//
//  PKUIPopupLink.swift
//
//  Created by Plumk on 2019/4/23.
//  Copyright © 2019 Plumk. All rights reserved.
//


import Foundation


/// 弹窗管理链
/// 保证当前只有一个弹窗在显示中
public class PKUIPopupLink {
    public static let `default` = PKUIPopupLink()
    public private(set) var popups = [PKUIPopup]()
    
    public var popCallback: ((_ link: PKUIPopupLink) -> Void)?
    
    public init() {}
    
    private func findInsertIndex(_ popup: PKUIPopup) -> Int {
        var low = 0
        var high = self.popups.count - 1
        
        while low <= high {
            let mid = low + (high - low) / 2
            if self.popups[mid].priority.rawValue == popup.priority.rawValue {
                
                var offset = mid
                while offset < self.popups.count {
                    if popup.priority.rawValue < self.popups[offset].priority.rawValue {
                        break
                    }
                    offset += 1
                }
                
                return offset
            } else if self.popups[mid].priority.rawValue < popup.priority.rawValue {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        return low
    }
    
    func push(_ popup: PKUIPopup) {
        
        /// 判断优先级
        if let last = self.popups.last {
            if popup.priority.rawValue >= last.priority.rawValue {
                last.suspend(animate: true)
            } else {
                popup.suspend(animate: false)
            }
        }
        self.popups.insert(popup, at: self.findInsertIndex(popup))
    }
    
    func pop() {
        self.popups.removeLast()
        self.popups.last?.resumne()
        self.popCallback?(self)
    }
    
    func remove(_ popup: PKUIPopup) {
        if let idx = self.popups.firstIndex(of: popup) {
            self.popups.remove(at: idx)
        }
    }
    
    func isLast(_ popup: PKUIPopup) -> Bool {
        return self.popups.last == popup
    }
    
    public func removeAll() {
        self.popups.removeAll()
    }
}
