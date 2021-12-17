//
//  PKUIMultimenuTableView.swift
//  PKit
//
//  Created by Plumk on 2020/3/12.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

fileprivate extension IndexPath {
    func equal(_ other: IndexPath?) -> Bool {
        guard let other = other else {
            return false
        }
        return row == other.row && section == other.section
    }
}

@IBDesignable
open class PKUIMultimenuTableView: UITableView {

    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commInit()
    }
    
    @IBOutlet open weak var multimenuDatasource: PLMultimenuDatasource?
    
    private var prevAllowsSelection = false
    private var menuPanGesture: PLMenuPanGestureRecognizer!
    private var multimenu: PLCellMultimenu!
    private var multimenuAttackIndexPath: IndexPath?
    
    open func commInit() {
        self.menuPanGesture = PLMenuPanGestureRecognizer.init(target: self, action: #selector(menuPanGestureHandle(_:)))
        self.menuPanGesture.delaysTouchesBegan = false
        self.menuPanGesture.delaysTouchesEnded = false
        self.menuPanGesture.delegate = self.menuPanGesture
        self.menuPanGesture.clickHandler = {[weak self] in
            self?.menuPanGestureClickHandle()
        }
        self.addGestureRecognizer(self.menuPanGesture)
        
        self.panGestureRecognizer.addTarget(self, action: #selector(originPanGestureHandle(_:)))
        self.panGestureRecognizer.require(toFail: self.menuPanGesture)
        
    }
    
    fileprivate func releaseMenuWrapper(animation: Bool = true) {
        if let multimenu = self.multimenu {
            guard let cell = multimenu.holdView as? UITableViewCell else {
                return
            }
            
            cell.removeFromSuperview()
            cell.frame.origin.y = multimenu.frame.origin.y
            self.insertSubview(cell, aboveSubview: multimenu)
            
            if animation {
                UIView.animate(withDuration: 0.25, animations: {
                    cell.frame.origin.x = 0
                }) { (_) in
                    multimenu.removeFromSuperview()
                }
            } else {
                cell.frame.origin.x = 0
                multimenu.removeFromSuperview()
            }
            
            self.allowsSelection = self.prevAllowsSelection
            
            self.multimenuAttackIndexPath = nil
            self.multimenu = nil
        }
    }
    
    @objc fileprivate func originPanGestureHandle(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            /// tableview 开始滑动关闭当前菜单
            self.releaseMenuWrapper()
        }
    }
    
    @objc fileprivate func menuPanGestureHandle(_ sender: PLMenuPanGestureRecognizer) {
        
        let point = sender.location(in: self)
        
        var state = 0
        defer {
            self.multimenu?.upadtePoint(point, state: state)
        }
        
        switch sender.state {
        case .began:
            
            
            guard let indexPath = self.indexPathForRow(at: point) else {
                return
            }
            
            guard let cell = self.cellForRow(at: indexPath) else {
                return
            }
            
            // 相同的cell 不处理
            guard self.multimenu?.holdView != cell else {
                return
            }
            self.releaseMenuWrapper()
            
            guard self.dataSource?.tableView?(self, canEditRowAt: indexPath) ?? false else {
                return
            }
            
            guard let actions = self.multimenuDatasource?.tableView?(self, menuActionsForRowAt: indexPath) else {
                return
            }
            
            self.multimenuAttackIndexPath = indexPath
            self.prevAllowsSelection = self.allowsSelection
            self.allowsSelection = false
            
            self.multimenu = PLCellMultimenu.init(frame: cell.frame)
            self.multimenu.backgroundColor = .clear
            self.multimenu.setupActions(actions)
            self.insertSubview(self.multimenu, aboveSubview: cell)
            
            cell.frame.origin = .zero
            self.multimenu.holdView = cell
            self.multimenu.addSubview(cell)
            
            state = 0
        case .changed:
            state = 1
        default:
            state = 2
        }
    }
    
    
    /// 菜单手势直接点击
    fileprivate func menuPanGestureClickHandle() {
        
        if self.multimenu != nil {
            let point = self.menuPanGesture.location(in: self)
            
            let ip = self.multimenuAttackIndexPath
            let action = self.multimenu.fetchAction(self.multimenu.convert(point, from: self))
            defer {
                if let action = action {
                    action.handler?(action, ip!)
                }
            }
            self.releaseMenuWrapper()
        }
    }
    
    // MARK: - Override Reload/Insert/Move/Delete 都需要释放菜单
    open override func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        if self.multimenuAttackIndexPath?.equal(indexPath) ?? false {
            self.releaseMenuWrapper(animation: false)
        }
        
        super.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    open override func deselectRow(at indexPath: IndexPath, animated: Bool) {
        if self.multimenuAttackIndexPath?.equal(indexPath) ?? false {
            self.releaseMenuWrapper(animation: false)
        }
        
        super.deselectRow(at: indexPath, animated: animated)
    }
    
    open override func reloadData() {
        self.releaseMenuWrapper(animation: false)
        super.reloadData()
    }
    
    open override func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        if let ip = self.multimenuAttackIndexPath {
            if sections.contains(ip.section) {
                self.releaseMenuWrapper(animation: false)
            }
        }
        super.reloadSections(sections, with: animation)
    }
    
    open override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        if indexPaths.contains(where: {$0.equal(self.multimenuAttackIndexPath)}) {
            self.releaseMenuWrapper(animation: false)
        }
        super.reloadRows(at: indexPaths, with: animation)
    }
    
    open override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        if let ip = self.multimenuAttackIndexPath {
            if sections.contains(ip.section) {
                self.releaseMenuWrapper(animation: false)
            }
        }
        super.insertSections(sections, with: animation)
    }
    
    open override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        if indexPaths.contains(where: {$0.equal(self.multimenuAttackIndexPath)}) {
            self.releaseMenuWrapper(animation: false)
        }
        super.insertRows(at: indexPaths, with: animation)
    }
    
    open override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        if let ip = self.multimenuAttackIndexPath {
            if sections.contains(ip.section) {
                self.releaseMenuWrapper(animation: false)
            }
        }
        super.deleteSections(sections, with: animation)
    }
    
    open override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        if indexPaths.contains(where: {$0.equal(self.multimenuAttackIndexPath)}) {
            self.releaseMenuWrapper(animation: false)
        }
        super.deleteRows(at: indexPaths, with: animation)
    }
    
    open override func moveSection(_ section: Int, toSection newSection: Int) {
        if let ip = self.multimenuAttackIndexPath {
            if ip.section == section || ip.section == newSection {
                self.releaseMenuWrapper(animation: false)
            }
        }
        super.moveSection(section, toSection: newSection)
    }
    
    open override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        if let ip = self.multimenuAttackIndexPath {
            if ip.equal(indexPath) || ip.equal(newIndexPath) {
                self.releaseMenuWrapper(animation: false)
            }
        }
        super.moveRow(at: indexPath, to: newIndexPath)
    }
}

// MARK: - PLMenuPanGestureRecognizer 菜单滑动手势
fileprivate class PLMenuPanGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {

    private var beginPoint = CGPoint.zero
    var clickHandler: (()->Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.beginPoint = self.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let point = self.location(in: self.view)
        
        if self.state == .possible {
            if abs(point.y - self.beginPoint.y) > 10 {
                self.state = .failed
            } else if abs(point.x - self.beginPoint.x) > 10 {
                self.state = .began
            }
            
        } else if self.state == .began || self.state == .changed {
            self.state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .changed || self.state == .began {
            self.state = .ended
            self.state = .possible
        } else {
            self.state = .failed
            // 未开始手势判断为点击
            self.clickHandler?()
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .changed || self.state == .began {
            self.state = .ended
            self.state = .possible
        } else {
            self.state = .failed
            // 未开始手势判断为点击
            self.clickHandler?()
        }
    }
    
}


// MARK: - PLCellMultimenu 菜单
fileprivate class PLCellMultimenu: UIView {
    
    weak var holdView: UIView?
    
    var items = [PLCellMultimenuItem]()
    var maximumWidth: CGFloat = 0
    
    var beginPoint: CGPoint = .zero
    var point: CGPoint = .zero
    
    /// 更新point
    /// - Parameters:
    ///   - point: current point
    ///   - state: state 0==begin 1==moved  2==end
    func upadtePoint(_ point: CGPoint, state: Int) {
        if state == 0 {
            self.beginPoint = point
            self.point = point
        } else if state == 1 {
            
            var mius = self.point.x - point.x
            
            var x = self.holdView?.frame.origin.x ?? 0
            let progress = abs(x) / self.maximumWidth
            mius *= progress > 1.0 ? 0.3 - (progress - 1) * 0.3 : 1
            x = min(0, x - mius)
            self.holdView?.frame.origin.x = x
            self.items.forEach({$0.fllow(abs(x), maximumWidth: self.maximumWidth)})
            
        } else {
            
            guard let view = self.holdView else {
                return
            }
            
            var dur: CGFloat = 0
            var endX: CGFloat = 0
            
            if self.beginPoint.x - point.x > 0 {
                // 向←
                dur = (1 - abs(view.frame.minX) / self.maximumWidth) * 0.25
                endX = self.maximumWidth * -1
            } else {
                // 向→
                dur = (1 - (self.maximumWidth - abs(view.frame.minX)) / self.maximumWidth) * 0.25
                endX = 0
            }
            
            UIView.animate(withDuration: TimeInterval(dur), delay: 0, options: .curveEaseOut, animations: {
                self.holdView?.frame.origin.x = endX
                self.items.forEach({$0.completeFllow(isOpen: endX < 0)})
            }) { (_) in
                
            }
        }
        self.point = point
    }
    
    func setupActions(_ actions: [PLMultimenuAction]) {
        
        let bounds = self.bounds
        var left = bounds.width
        for action in actions {
            
            guard let item = PLCellMultimenuItem.init(action: action, frame: .init(x: bounds.width, y: 0, width: bounds.width, height: bounds.height)) else {
                return
            }
            item.originX = bounds.width
            item.endX = left - item.visibleWidth
            left = item.endX
            self.maximumWidth += item.visibleWidth
            
            self.addSubview(item)
            self.sendSubviewToBack(item)
            self.items.append(item)
        }
    }
    
    func fetchAction(_ point: CGPoint) -> PLMultimenuAction? {
        return self.items.filter({$0.frame.contains(point)}).first?.action
    }
}

// MARK: - PLCellMultimenuItem 菜单项
fileprivate class PLCellMultimenuItem: UIView {
    
    var action: PLMultimenuAction?
    
    var visibleWidth: CGFloat = 0
    var originX: CGFloat = 0
    var endX: CGFloat = 0
    
    init?(action: PLMultimenuAction, frame: CGRect) {
        guard let view = action.view else {
            return nil
        }
        super.init(frame: frame)
        
        self.visibleWidth = view.bounds.width + action.xPadding * 2
        view.frame.origin = .init(x: (self.visibleWidth - view.bounds.width) / 2,
                                  y: (self.bounds.height - view.bounds.height) / 2)
        self.addSubview(view)
        
        self.action = action
        self.backgroundColor = action.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func fllow(_ openWidth: CGFloat, maximumWidth: CGFloat) {
        
        let width = self.originX - self.endX
        let rate = width / maximumWidth
        self.frame.origin.x = self.originX - openWidth * rate
    }
    
    func completeFllow(isOpen: Bool) {
        if isOpen {
            self.frame.origin.x = self.endX
        } else {
            self.frame.origin.x = self.originX
        }
    }
}


// MARK: - PLMultimenuAction 菜单项配置
open class PLMultimenuAction: NSObject {
    public typealias Handler = (PLMultimenuAction, IndexPath)->Void
    
    open var xPadding: CGFloat = 25
    open var backgroundColor = UIColor.red
    
    open var view: UIView?
    open var handler: Handler?
    
    public convenience init(view: UIView?, backgroundColor: UIColor = .red, handler: Handler?) {
        self.init()
        self.view = view
        self.backgroundColor = backgroundColor
        self.handler = handler
    }
}

// MARK: - PLMultiMenuDelegate
@objc public protocol PLMultimenuDatasource: NSObjectProtocol {
    @objc optional func tableView(_ tableView: UITableView, menuActionsForRowAt indexPath: IndexPath) -> [PLMultimenuAction]
}
