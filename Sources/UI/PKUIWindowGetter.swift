//
//  PKUIWindowGetter.swift
//  PKit
//
//  Created by Plumk on 2022/5/16.
//

import Foundation


public struct PKUIWindowGetter {
    
    /// 获取window 兼容iOS13
    public static var window: UIWindow? {

        if #available(iOS 13.0, *) {
            if let delegate = self.windowScene?.delegate as? UIWindowSceneDelegate {
                return delegate.window!
            }
        }
        
        return UIApplication.shared.delegate?.window!
    }
    
    
    /// 获取keyWindow 兼容iOS13
    public static var keyWindow: UIWindow? {
        
        if #available(iOS 13.0, *) {
            if let scene = self.windowScene {
                
                if #available(iOS 15.0, *) {
                    return scene.keyWindow
                }
                
                return scene.windows.first(where: { $0.isKeyWindow })
            }
        }
        
        return UIApplication.shared.keyWindow
    }
    
    
    /// 状态栏frame
    public static var statusBarFrame: CGRect {
        
        if #available(iOS 13.0, *) {
            if let scene = self.windowScene {
                return scene.statusBarManager?.statusBarFrame ?? .zero
            }
        }
        
        return UIApplication.shared.statusBarFrame
        
    }
    
    /// 获取安全边距
    public static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.window?.safeAreaInsets ?? .zero
        }
        
        return .zero
    }
    
    /// 获取iOS13之后的scene
    @available(iOS 13.0, *)
    public static var windowScene: UIWindowScene? {
        
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene else {
            return nil
        }
        
        return windowScene
    }
    
}
