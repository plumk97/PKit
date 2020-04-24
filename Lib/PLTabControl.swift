
//
//  PLTabControl.swift
//  PLKit
//
//  Created by iOS on 2020/4/9.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class PLTabControl: UIView {
    
    /// 选中 selectedIndex 改变block
    var didChangeSelectedIndexBlock: ((Int)->Void)?
    
    /// 没有选中状态下的缩小值
    var zoomOutRatio: CGFloat = 0.6 {
        didSet {
            transactionAnimation(duration: 0) {
                self.updateDisplay()
            }
        }
    }
    
    /// 最大化字体大小
    var maximizeFont: UIFont = .boldSystemFont(ofSize: 22) { didSet { self.reload() }}
    
    /// 间距
    var spacing: CGFloat = 30 { didSet { self.reload() }}
    
    /// items
    var items: [Item]? { didSet { self.reload() }}
    
    /// 指示条颜色
    var indicateColor: UIColor = .init(red: 1, green: 0, blue: 0, alpha: 1) {
        didSet {
            self.indicateBar?.backgroundColor = indicateColor.cgColor
        }
    }
    
    /// 指示条与标签宽度比率
    var indicateWidthRatio: CGFloat = 0.4 {
        didSet {
            transactionAnimation(duration: 0) {
                self.updateDisplay()
            }
        }
    }
    
    /// 指示条高度
    var indicateHeight: CGFloat = 3 { didSet { self.reloadIndicateBar() } }
    
    /// 指示条与标签的间距
    var bothIndicateBarLabelSpacing: CGFloat = 5 {
        didSet {
            transactionAnimation(duration: 0) {
                self.updateDisplay()
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    /// 当前选中下标
    fileprivate(set) var selectedIndex: Int = 0
    
    /// 显示使用的text layer
    fileprivate var labels = [CATextLayer]()
    
    /// 每个label的frame
    fileprivate var labelFrames = [CGRect]()
    
    /// 当前内容大小
    fileprivate var labelContentSize: CGSize = .zero
    
    /// 是否正在交互动画中
    fileprivate(set) var isInInteractionAnimation: Bool = false
    
    /// 交互动画进度值
    fileprivate var interactionAnimationProgress: CGFloat = 0
    
    /// 底部指示条
    private var indicateBar: CALayer!
    
    init(items: [Item], setup: ((PLTabControl)->Void)? = nil) {
        super.init(frame: .zero)
        
        setup?(self)
        
        self.indicateBar = CALayer()
        self.indicateBar.contentsScale = UIScreen.main.scale
        self.reloadIndicateBar()
        self.layer.addSublayer(self.indicateBar)
        
        self.items = items
        self.reload()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    /// 加载界面
    fileprivate func reload() {
        guard let items = self.items else {
            return
        }
        self.labels.forEach({ $0.removeFromSuperlayer() })
        self.labels.removeAll()
        self.labelFrames.removeAll()
        
        var right: CGFloat = 0
        var maxHeight: CGFloat = 0
        

        let fontRef = CGFont.init(self.maximizeFont.fontName as CFString)
        for item in items {
            
            let nstitle = item.title as NSString
            
            let maxSize = nstitle.size(withAttributes: [.font: self.maximizeFont])
            
            let frame = CGRect.init(x: right, y: 0, width: maxSize.width, height: maxSize.height)
            self.labelFrames.append(frame)
            
            let label = CATextLayer()
            label.contentsScale = UIScreen.main.scale
            
            label.string = item.title
            label.foregroundColor = item.color.cgColor
            
            label.font = fontRef
            label.fontSize = self.maximizeFont.pointSize
            label.frame = frame
            
            self.layer.addSublayer(label)
            self.labels.append(label)
            
            right = label.frame.maxX + self.spacing
            maxHeight = max(maxHeight, label.frame.height)
        }
        
        self.labelContentSize = .init(width: right - self.spacing, height: maxHeight)
        self.invalidateIntrinsicContentSize()
        
        transactionAnimation(duration: 0) {
            self.updateDisplay()
        }
    }
    
    
    /// 重新加载指示器
    fileprivate func reloadIndicateBar() {
        guard self.indicateBar != nil else {
            return
        }
        
        self.indicateBar.frame.size.height = self.indicateHeight
        self.indicateBar.cornerRadius = self.indicateHeight / 2
        self.indicateBar.backgroundColor = self.indicateColor.cgColor
        
        self.invalidateIntrinsicContentSize()
    }
    
    /// 更新显示
    func updateDisplay() {
        
        guard let items = self.items else {
            return
        }
        
        
        if self.isInInteractionAnimation {
            // interaction animation state
            let progress = self.interactionAnimationProgress
            
            var nextSelectedIndex = self.selectedIndex
            if progress > 0 {
                guard nextSelectedIndex + 1 < items.count else {
                    return
                }
                nextSelectedIndex += 1
            } else if progress < 0 {
                guard nextSelectedIndex - 1 >= 0 else {
                    return
                }
                nextSelectedIndex -= 1
            } else {
                return
            }
            
            let selectedItem = items[self.selectedIndex]
            let nextSelectedItem = items[nextSelectedIndex]
            
            
            
            
            let tmpNextSelectedColor = PLKit.Color.makeTransitionColor(from: selectedItem.color, to: nextSelectedItem.selectedColor, progress: abs(progress))
            let tmpSelectedColor = PLKit.Color.makeTransitionColor(from: selectedItem.selectedColor, to: nextSelectedItem.color, progress: abs(progress))
            let tmpColor = PLKit.Color.makeTransitionColor(from: selectedItem.color, to: nextSelectedItem.color, progress: abs(progress))
            
            
            let b = (1 - self.zoomOutRatio) * abs(progress)
            for (idx, label) in self.labels.enumerated() {
                
                if idx == self.selectedIndex {
                    let ratio = 1 - b
                    label.transform = CATransform3DScale(CATransform3DIdentity, ratio, ratio, 1)
                } else if idx == nextSelectedIndex {
                    
                    let ratio = self.zoomOutRatio + b
                    label.transform = CATransform3DScale(CATransform3DIdentity, ratio, ratio, 1)
                }
                
                if idx == nextSelectedIndex {
                    label.foregroundColor = tmpNextSelectedColor.cgColor
                } else if idx == self.selectedIndex {
                    label.foregroundColor = tmpSelectedColor.cgColor
                } else {
                    label.foregroundColor = tmpColor.cgColor
                }
            }
            
            // -- 更新指示条
            let labelFrame = self.labelFrames[self.selectedIndex]
            let nextLabelFrame = self.labelFrames[nextSelectedIndex]
            
            let width = labelFrame.width * self.indicateWidthRatio
            let nextWidth = nextLabelFrame.width * self.indicateWidthRatio
            
            if labelFrame.midX < nextLabelFrame.midX {
                // 向→
                let minX = labelFrame.midX - width / 2
                let maxX = nextLabelFrame.midX + nextWidth / 2
                
                let indicateFrame = CGRect.init(
                    x: minX,
                    y: nextLabelFrame.maxY + self.bothIndicateBarLabelSpacing,
                    width: (maxX - minX - nextWidth) * abs(progress) + nextWidth,
                    height: self.indicateHeight)
                
                self.indicateBar.frame = indicateFrame
                
            } else {
                // 向←
                let minX = nextLabelFrame.midX - nextWidth / 2
                let maxX = labelFrame.midX + width / 2
                
                let indicateFrame = CGRect.init(
                    x: minX + (maxX - minX - width) *  (1 - abs(progress)),
                    y: nextLabelFrame.maxY + self.bothIndicateBarLabelSpacing,
                    width: (maxX - minX - width) * abs(progress) + width,
                    height: self.indicateHeight)
                
                self.indicateBar.frame = indicateFrame
            }
            
            return
        }
        
        guard self.selectedIndex < items.count else {
            return
        }
    
        let selectedItem = items[self.selectedIndex]
        for (idx, label) in self.labels.enumerated() {
            if idx == self.selectedIndex {
                label.transform = CATransform3DIdentity
                label.foregroundColor = selectedItem.selectedColor.cgColor
                
                // 设置指示条frame
                let labelFrame = self.labelFrames[idx]
                let indicateWidth = labelFrame.width * self.indicateWidthRatio
                let indicateFrame = CGRect.init(x: labelFrame.midX - indicateWidth / 2, y: labelFrame.maxY + self.bothIndicateBarLabelSpacing,
                                                width: indicateWidth, height: self.indicateHeight)
                self.indicateBar.frame = indicateFrame
                
            } else {
                label.transform = CATransform3DScale(CATransform3DIdentity, self.zoomOutRatio, self.zoomOutRatio, 1)
                label.foregroundColor = selectedItem.color.cgColor
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: self.labelContentSize.width, height: self.labelContentSize.height + self.indicateHeight + self.bothIndicateBarLabelSpacing)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// 判断点击哪一个item
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        for (idx, frame) in self.labelFrames.enumerated() {
            if frame.contains(point) {
                if idx != self.selectedIndex {
                    self.setSelectedIndex(idx, animtion: true)
                    self.didChangeSelectedIndexBlock?(idx)
                }
                break
            }
        }
    }

    /// 改变隐式动画
    /// - Parameters:
    ///   - duration: 持续时间 0为不需要隐式动画
    ///   - exec: 执行block
    func transactionAnimation(duration: CFTimeInterval, exec: ()->Void) {
        CATransaction.begin()
        if duration <= 0 {
            CATransaction.setDisableActions(true)
        } else {
            CATransaction.setAnimationDuration(duration)
        }
        exec()
        CATransaction.commit()
    }
    
    // -- selected
    
    /// 设置当前选中Item
    /// - Parameters:
    ///   - index: 0 -- item.count - 1 其他值无效
    ///   - animtion: 是否需要动画
    func setSelectedIndex(_ index: Int, animtion: Bool) {
        
        let count = self.items?.count ?? 0
        guard index < count && index >= 0 else {
            return
        }
        
        self.selectedIndex = index
        if animtion {
            transactionAnimation(duration: 0.35) {
                self.updateDisplay()
            }
        } else {
            transactionAnimation(duration: 0) {
                self.updateDisplay()
            }
        }
    }
    
    func getLabel(index: Int) -> CATextLayer? {
        guard index >= 0 && index < self.labels.count else {
            return nil
        }
        return self.labels[index]
    }
    
    // MARK: - interaction Animation
    
    /// 开始交互动画
    func startInteractionAnimation() {
        guard !self.isInInteractionAnimation else {
            return
        }
        self.isInInteractionAnimation = true
        self.interactionAnimationProgress = 0
    }
    
    /// 进度改变 负数为← 正数 →
    /// - Parameter progress: -1.0 - 0 - 1.0
    func changeInteractionAnimation(progress: CGFloat) {
        guard self.isInInteractionAnimation else {
            return
        }
        
        self.interactionAnimationProgress = progress
        transactionAnimation(duration: 0) {
            self.updateDisplay()
        }
    }
    
    /// 结束交互动画
    /// - Parameter targetIndex: 结束之后选中的下标
    func endInteractionAnimation(targetIndex: Int) {
        guard self.isInInteractionAnimation else {
            return
        }
        self.isInInteractionAnimation = false
        
        
        let count = self.items?.count ?? 0
        if targetIndex < count && targetIndex >= 0 && targetIndex != self.selectedIndex {
            self.selectedIndex = targetIndex
        }
        
        transactionAnimation(duration: 0.25) {
            self.updateDisplay()
        }

        self.interactionAnimationProgress = 0
    }
    
    
    // MARK: - Bind ScrollView
    fileprivate var beginPoint: CGPoint = .zero
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset
        let progress = (offset.x - self.beginPoint.x) / scrollView.frame.width
        self.changeInteractionAnimation(progress: progress)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.beginPoint = offset
        self.startInteractionAnimation()
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee
        let page = Int(offset.x / scrollView.frame.width)
        self.endInteractionAnimation(targetIndex: page)
    }
    
}

extension PLTabControl {
    
    class Item: NSObject {
        var title: String!
        
        var color: UIColor = .white
        var selectedColor: UIColor = .lightGray
                
        init(title: String, color: UIColor, selectedColor: UIColor) {
            super.init()
            
            self.title = title
            self.color = color
            self.selectedColor = selectedColor
        }
    }
}
