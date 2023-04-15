//
//  PKUIStackView.swift
//  PKit
//
//  Created by Plumk on 2021/7/20.
//  Copyright © 2021 Plumk. All rights reserved.
//

import UIKit

open class PKUIStackView: UIView {

    open var axis: NSLayoutConstraint.Axis = .horizontal

    open var distribution: UIStackView.Distribution = .fill
    
    open var alignment: UIStackView.Alignment = .fill
    
    
    open var arrangedSubviews: [UIView] {
        return self.wraps.map({ $0.view })
    }
    
    open var spacings: [CGFloat] {
        return self.wraps.map({ $0.spacing })
    }
    
    private var wraps = [Wrap]()
    private var innerContentSize: CGSize = .init(width: -1, height: -1)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
    }
    
    
    deinit {
        self.wraps.forEach({
            $0.view.removeObserver(self, forKeyPath: "hidden")
        })
    }
    
    /// 移除旧的约束
    private func removeOldConstraints() {
        
        self.wraps.forEach({
            $0.removeOldConstraints()
        })
        
        self.constraints.forEach({
            if $0.isKind(of: PKConstraint.self) {
                self.removeConstraint($0)
            }
        })
    }
    
    /// 监听view 是否隐藏 刷新界面
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let view = object as? UIView, keyPath == "hidden" else {
            return
        }
        
        if self.distribution == .equalSpacing {
            let wrap = self.wraps.first(where: { $0.view == view })
            wrap?.gapGuide.isHidden = true
        }
        
        self.setNeedsUpdateConstraints()
    }
    
    /// 添加一个view
    /// - Parameters:
    ///   - view:
    ///   - spacing:
    open func addArrangedSubview(_ view: UIView, afterSpacing spacing: CGFloat) {

        let wrap = Wrap()
        wrap.spacing = spacing
        wrap.view = view
        
        self.wraps.append(wrap)
        self.setupWrap(wrap)
        
        self.setNeedsUpdateConstraints()
    }
    
    /// 插入一个view到指定下标 越界则不插入
    /// - Parameters:
    ///   - view:
    ///   - index:
    ///   - spacing:
    open func insertArrangedSubview(_ view: UIView, index: Int, afterSpacing spacing: CGFloat) {
        guard index >= 0 && index <= self.wraps.count else {
            return
        }
        
        let wrap = Wrap()
        wrap.spacing = spacing
        wrap.view = view
        
        self.wraps.insert(wrap, at: index)
        self.setupWrap(wrap)
        
        self.setNeedsUpdateConstraints()
    }
    
    /// 替换一个view 到指定下标 越界则不替换
    /// - Parameters:
    ///   - view:
    ///   - index:
    ///   - spacing:
    open func replaceArrangedSubview(_ view: UIView, index: Int, afterSpacing spacing: CGFloat) {
        guard index >= 0 && index < self.wraps.count else {
            return
        }

        let wrap = Wrap()
        wrap.spacing = spacing
        wrap.view = view
        
        self.removeWrap(self.wraps[index])
        self.wraps[index] = wrap
        self.setupWrap(wrap)
        
        self.setNeedsUpdateConstraints()
    }
    
    /// 移除一个view
    /// - Parameter view:
    open func removeArrangedSubview(_ view: UIView) {
        guard let idx = self.wraps.firstIndex(where: { $0.view == view }) else {
            return
        }
        
        self.removeWrap(self.wraps.remove(at: idx))
        self.setNeedsUpdateConstraints()
    }
    
    
    private func setupWrap(_ wrap: Wrap) {
        wrap.view.translatesAutoresizingMaskIntoConstraints = false
        wrap.view.addObserver(self, forKeyPath: "hidden", options: .new, context: nil)
        
        self.addSubview(wrap.view)
        
        if (self.distribution == .equalSpacing || self.distribution == .equalCentering) && self.wraps.count > 1 {
            wrap.gapGuide.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(wrap.gapGuide)
        }
    }
    
    private func removeWrap(_ wrap: Wrap) {
        wrap.view.removeObserver(self, forKeyPath: "hidden")
        wrap.view.removeFromSuperview()
        wrap.gapGuide.removeFromSuperview()
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        var wraps = [Wrap]()
        for wrap in self.wraps {
            if !wrap.view.isHidden {
                wraps.append(wrap)
            }
        }

        guard wraps.count > 0 else {
            return
        }
    
        self.removeOldConstraints()
        
        switch self.axis {
        case .horizontal:
            self.horizontalLayoutSubviews(wraps: wraps)

        case .vertical:
            self.verticalLayoutSubviews(wraps: wraps)

        @unknown default:
            break
        }
    }
    
    /// 横向布局
    /// - Parameter wraps:
    private func horizontalLayoutSubviews(wraps: [Wrap]) {
        var constraints = [NSLayoutConstraint]()
        
        
        /// 设置垂直对齐
        func setAligmentConstraint(_ view: UIView) {
            if self.alignment == .fill {
                constraints.append(PKConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                constraints.append(PKConstraint.make(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            } else if self.alignment == .top {
                constraints.append(PKConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            } else if self.alignment == .center {
                constraints.append(PKConstraint.make(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            } else if self.alignment == .bottom {
                constraints.append(PKConstraint.make(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            }
        }
        
        
        let maxHeight = wraps.map({ $0.view.bounds.height }).max() ?? -1
        
        switch self.distribution {
        case .fill:
            
            
            for (idx, wrap) in wraps.enumerated() {
                
                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                } else {
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .trailing, multiplier: 1, constant: preWrap.spacing))
                }
                
                setAligmentConstraint(wrap.view)
            }


        case .fillEqually:
            
            for (idx, wrap) in wraps.enumerated() {
                
                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                } else {
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .trailing, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .width, relatedBy: .equal, toItem: wraps[0].view, attribute: .width, multiplier: 1, constant: 0))
                }
  
                
                setAligmentConstraint(wrap.view)
            }

            
            
        case .fillProportionally:
            
            let widths = wraps.map({
                let width = $0.view.constraints.filter({ $0.firstAttribute == .width && $0.secondItem == nil}).first?.constant ?? 0
                if (width <= 0) {
                    return $0.view.intrinsicContentSize.width
                }
                return width
            })
            
            for (idx, wrap) in wraps.enumerated() {
  
                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                } else {
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .trailing, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .width, relatedBy: .equal, toItem: wraps[0].view, attribute: .width, multiplier: widths[idx] / widths[0], constant: 0))
                }
  

                setAligmentConstraint(wrap.view)
            }
            
            
        case .equalSpacing:
            
            for (idx, wrap) in wraps.enumerated() {
                if idx == 0 {

                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                } else if idx == 1 {
                    
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .trailing, multiplier: 1, constant: 0))
                    
                    /// - 设置第一个 GapView 作为后续的 GapView参考
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerY, relatedBy: .equal, toItem: preWrap.view, attribute: .centerY, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: preWrap.spacing, priority: .defaultLow))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .trailing, multiplier: 1, constant: 0))
                    
                } else {
                    
                    let wrap1 = wraps[1]
                    let preWrap = wraps[idx - 1]
                    
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .trailing, multiplier: 1, constant: 0))
                    
                    /// - 参考第一个 wrap 的 GapView 设置
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerY, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .centerY, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .height, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .width, multiplier: 1, constant: 0))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .trailing, multiplier: 1, constant: 0))
                }

                setAligmentConstraint(wrap.view)
            }
            
            
        case .equalCentering:
            for (idx, wrap) in wraps.enumerated() {
                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                } else if idx == 1 {
                    
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .centerX, multiplier: 1, constant: 0))
                    
                    /// - 设置第一个 GapView 作为后续的 GapView参考
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerY, relatedBy: .equal, toItem: preWrap.view, attribute: .centerY, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: preWrap.spacing, priority: .defaultLow))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .centerX, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .trailing, multiplier: 1, constant: 0))
                    
                } else {
                    
                    let wrap1 = wraps[1]
                    let preWrap = wraps[idx - 1]
                    
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .leading, relatedBy: .equal, toItem: preWrap.view, attribute: .centerX, multiplier: 1, constant: 0))
                    
                    /// - 参考第一个 wrap 的 GapView 设置
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerY, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .centerY, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .height, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .width, multiplier: 1, constant: 0))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .centerX, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .trailing, multiplier: 1, constant: 0))
                }

                setAligmentConstraint(wrap.view)
            }
            
        @unknown default:
            break
        }
        
        let view = wraps.last!.view
        constraints.append(PKConstraint.make(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))

        self.addConstraints(constraints)
        if maxHeight != self.innerContentSize.height {
            self.innerContentSize.height = maxHeight
            self.invalidateIntrinsicContentSize()
        }
    }
    
    /// 纵向布局
    private func verticalLayoutSubviews(wraps: [Wrap]) {
        var constraints = [NSLayoutConstraint]()
        
        
        /// 设置垂直对齐
        func setAligmentConstraint(_ view: UIView) {
            if self.alignment == .fill {
                constraints.append(PKConstraint.make(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
                constraints.append(PKConstraint.make(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            } else if self.alignment == .leading {
                constraints.append(PKConstraint.make(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
            } else if self.alignment == .center {
                constraints.append(PKConstraint.make(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            } else if self.alignment == .trailing {
                constraints.append(PKConstraint.make(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            }
        }
        
        
        let maxWidth = wraps.map({ $0.view.bounds.width }).max() ?? -1
        
        switch self.distribution {
        case .fill:
            
            for (idx, wrap) in wraps.enumerated() {
                
                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                } else {
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .bottom, multiplier: 1, constant: preWrap.spacing))
                }
                
                setAligmentConstraint(wrap.view)
            }


        case .fillEqually:
            
            for (idx, wrap) in wraps.enumerated() {
                
                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                } else {
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .bottom, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .height, relatedBy: .equal, toItem: wraps[0].view, attribute: .height, multiplier: 1, constant: 0))
                }
                setAligmentConstraint(wrap.view)
            }

            
            
        case .fillProportionally:
            
            let heights = wraps.map({
                let height = $0.view.constraints.filter({ $0.firstAttribute == .height && $0.secondItem == nil}).first?.constant ?? 0
                if (height <= 0) {
                    return $0.view.intrinsicContentSize.height
                }
                return height
            })
        
            for (idx, wrap) in wraps.enumerated() {

                if idx == 0 {
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                    
                } else {
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .bottom, multiplier: 1, constant: preWrap.spacing))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .height, relatedBy: .equal, toItem: preWrap.view, attribute: .height, multiplier: heights[idx] / heights[0], constant: 0))
                }
                setAligmentConstraint(wrap.view)
            }

            
        case .equalSpacing:
            
            for (idx, wrap) in wraps.enumerated() {
                if idx == 0 {

                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                } else if idx == 1 {
                    
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .bottom, multiplier: 1, constant: 0))
                    
                    /// - 设置第一个 GapView 作为后续的 GapView参考
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerX, relatedBy: .equal, toItem: preWrap.view, attribute: .centerX, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: preWrap.spacing, priority: .defaultLow))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .bottom, multiplier: 1, constant: 0))
                    
                } else {
                    
                    let wrap1 = wraps[1]
                    let preWrap = wraps[idx - 1]
                    
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .bottom, multiplier: 1, constant: 0))
                    
                    /// - 参考第一个 wrap 的 GapView 设置
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerX, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .centerX, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .width, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .height, multiplier: 1, constant: 0))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .bottom, multiplier: 1, constant: 0))
                }

                setAligmentConstraint(wrap.view)
            }
            
        case .equalCentering:
            
            for (idx, wrap) in wraps.enumerated() {
                if idx == 0 {

                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                } else if idx == 1 {
                    
                    let preWrap = wraps[idx - 1]
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .centerY, multiplier: 1, constant: 0))
                    
                    /// - 设置第一个 GapView 作为后续的 GapView参考
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerX, relatedBy: .equal, toItem: preWrap.view, attribute: .centerX, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: preWrap.spacing))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: preWrap.spacing, priority: .defaultLow))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .centerY, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .bottom, multiplier: 1, constant: 0))
                    
                } else {
                    
                    let wrap1 = wraps[1]
                    let preWrap = wraps[idx - 1]
                    
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .top, relatedBy: .equal, toItem: preWrap.view, attribute: .centerY, multiplier: 1, constant: 0))
                    
                    /// - 参考第一个 wrap 的 GapView 设置
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .centerX, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .centerX, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .width, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .width, multiplier: 1, constant: 0))
                    constraints.append(PKConstraint.make(item: wrap.gapGuide, attribute: .height, relatedBy: .equal, toItem: wrap1.gapGuide, attribute: .height, multiplier: 1, constant: 0))
                    
                    constraints.append(PKConstraint.make(item: wrap.view, attribute: .centerY, relatedBy: .equal, toItem: wrap.gapGuide, attribute: .bottom, multiplier: 1, constant: 0))
                }

                setAligmentConstraint(wrap.view)
            }
            
        @unknown default:
            break
        }
        
        let view = wraps.last!.view
        constraints.append(PKConstraint.make(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

        self.addConstraints(constraints)
        if maxWidth != self.innerContentSize.width {
            self.innerContentSize.width = maxWidth
            self.invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.innerContentSize
    }

}






// MARK: ---
extension PKUIStackView {
    
    fileprivate class GapGuide: UIView {}
    
    fileprivate class Wrap {
        
        let gapGuide = GapGuide()
        
        var view: UIView!
        var spacing: CGFloat = 0
        
        func removeOldConstraints() {
            
            self.gapGuide.removeConstraints(self.gapGuide.constraints)
            
            self.view.constraints.forEach({
                if $0.isKind(of: PKConstraint.self) {
                    self.view.removeConstraint($0)
                }
            })
        }
    }
}
