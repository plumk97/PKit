//
//  PLSlideVerify.swift
//  PLKit
//
//  Created by Plumk on 2019/7/3.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLSlideVerify: UIView {
    typealias SucceedCallback = ()->Void
    
    class Config: NSObject {
        var data: Any? // url/image
        var xR: CGFloat = 0.5 // 0 - 1
        var yR: CGFloat = 0.5 // 0 - 1
        
        init(data: Any?, xR: CGFloat = 0.5, yR: CGFloat = 0.5) {
            super.init()
            self.data = data
            self.xR = xR
            self.yR = yR
        }
    }
    
    var config: Config? {
        didSet {
            self.updateConfig()
        }
    }
    
    private(set) var imageView: UIImageView!
    fileprivate var clipImageView: UIImageView!
    fileprivate var slideAreaView: SlideAreaView!
    fileprivate var converControl: UIControl?
    
    fileprivate var succeedCallback: SucceedCallback?
    
    override init(frame: CGRect) {
        super.init(frame: .init(origin: frame.origin, size: .init(width: UIScreen.main.bounds.width - 60, height: 280)))
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        
        let titleLabel = UILabel()
        titleLabel.textColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.text = "请完成安全验证"
        self.addSubview(titleLabel)
        
        titleLabel.sizeToFit()
        titleLabel.frame.origin = .init(x: 15, y: 15)
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage.init(named: "icon_close"), for: .normal)
        closeBtn.sizeToFit()
        closeBtn.frame.origin = .init(x: bounds.width - closeBtn.frame.width - 15, y: titleLabel.frame.minY + (titleLabel.frame.height - closeBtn.frame.height) / 2)
        closeBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        self.addSubview(closeBtn)
        
        let spacingLine = UIView()
        spacingLine.backgroundColor = .init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        spacingLine.frame = .init(x: 0, y: titleLabel.frame.maxY + 15, width: bounds.width, height: 0.5)
        self.addSubview(spacingLine)
        
        self.imageView = UIImageView()
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.frame = .init(x: 15, y: spacingLine.frame.maxY + 15, width: bounds.width - 30, height: 150)
        self.imageView.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        self.addSubview(self.imageView)
        
        self.clipImageView = UIImageView()
        self.addSubview(self.clipImageView)
        
        self.slideAreaView = SlideAreaView.init(frame: .init(x: 15, y: self.imageView.frame.maxY + 15, width: bounds.width - 30, height: 35))
        self.addSubview(self.slideAreaView)
        
        
        self.slideAreaView.dragingCallback = {[unowned self] (r) in
            let rect = self.imageView.frame
            var clipRect = self.clipImageView.frame
            
            clipRect.origin.x = rect.minX + (rect.width - clipRect.width) * r
            self.clipImageView.frame = clipRect
        }
        
        self.slideAreaView.dragEndCallback = {[unowned self] (r) in
            
            guard let config = self.config else {
                return false
            }
            
            // 判断是否正确
            let success = abs(1 - r / config.xR) < 0.05
            if !success {
                UIView.animate(withDuration: 0.25, animations: {
                    self.clipImageView.frame.origin.x = self.imageView.frame.minX
                })
            } else {
                self.succeedCallback?()
                self.hide()
            }
            return success
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateConfig() {
        if let image = self.config?.data as? UIImage {
            self.reset(image)
            
        } else if let urlstr = self.config?.data as? String {
            guard let url = URL.init(string: urlstr) else {
                return
            }
            let session = URLSession.shared
            session.dataTask(with: url) { (data, res, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                let httpRes = res as? HTTPURLResponse
                guard httpRes?.statusCode == 200 else {
                    print("response code \(httpRes?.statusCode ?? -1)")
                    return
                }
                
                guard let data = data else {
                    return
                }
                if let image = UIImage.init(data: data) {
                    DispatchQueue.main.async {
                        self.reset(image)
                    }
                }
            }.resume()
        }
    }
    
    /// 重置图片 和 裁剪图片 根据 config
    ///
    /// - Parameter image:
    private func reset(_ image: UIImage) {
        guard let config = self.config else {
            return
        }
        
        let rect = CGRect.init(origin: .zero, size: self.imageView.bounds.size)
        let clipOrigin = CGPoint.init(x: (rect.width - 50) * config.xR, y: (rect.height - 50) * config.yR)
        
        let r = min(image.size.width / rect.width, image.size.height / rect.height)
        var imageRect = CGRect.zero
        imageRect.size = .init(width: image.size.width / r, height: image.size.height / r)
        imageRect.origin = .init(x: (rect.width - imageRect.width) / 2, y: (rect.height - imageRect.height) / 2)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        image.draw(in: imageRect)
        
        let originImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = .init(width: 0, height: 0)
        shadow.shadowBlurRadius = 10
        
        let clipPath = self.makeClipPath(origin: clipOrigin)
        UIColor.black.withAlphaComponent(0.5).setFill()
        clipPath.fill()
        
        // 绘制内阴影
        ctx?.saveGState()
        ctx?.clip(to: clipPath.bounds)
        ctx?.setShadow(offset: .zero, blur: 0, color: nil)
        ctx?.setAlpha(1)
        ctx?.beginTransparencyLayer(auxiliaryInfo: nil)

        let shadowColor = (shadow.shadowColor as? UIColor)!
        ctx?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadowColor.cgColor)
        ctx?.setBlendMode(.sourceOut)
        
        ctx?.beginTransparencyLayer(auxiliaryInfo: nil)
        shadowColor.setFill()
        clipPath.fill()
        ctx?.endTransparencyLayer()

        ctx?.endTransparencyLayer()
        ctx?.restoreGState()
        ////
        
        let renderImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.imageView.image = renderImage
        
        let cImage = self.clipImage(originImage, clipPath: clipPath)
        self.clipImageView.image = cImage
        self.clipImageView.sizeToFit()
        self.clipImageView.frame.origin = .init(x: self.imageView.frame.minX, y: self.imageView.frame.minY + clipOrigin.y)
    }
    
    /// 获取裁剪图片
    ///
    /// - Parameters:
    ///   - image: 原图
    ///   - clipPath: 裁剪路径
    /// - Returns:
    private func clipImage(_ image: UIImage, clipPath: UIBezierPath) -> UIImage {
        
        let bounds = clipPath.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        clipPath.apply(.init(translationX: -bounds.minX, y: -bounds.minY))
        ctx?.addPath(clipPath.cgPath)
        ctx?.clip()
        
        image.draw(at: .init(x: -bounds.minX, y: -bounds.minY))

        // 绘制内阴影
        ctx?.saveGState()
        ctx?.clip(to: clipPath.bounds)
        ctx?.setShadow(offset: .zero, blur: 0, color: nil)
        ctx?.setAlpha(1)
        ctx?.beginTransparencyLayer(auxiliaryInfo: nil)
        
        let shadowColor = UIColor.white
        ctx?.setShadow(offset: .zero, blur: 8, color: shadowColor.cgColor)
        ctx?.setBlendMode(.sourceOut)
        
        ctx?.beginTransparencyLayer(auxiliaryInfo: nil)
        shadowColor.setFill()
        clipPath.fill()
        ctx?.endTransparencyLayer()
        
        ctx?.endTransparencyLayer()
        ctx?.restoreGState()
        ////
        
        clipPath.lineWidth = 1
        UIColor.black.setStroke()
        clipPath.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 生成裁剪路径
    ///
    /// - Parameter origin: 起始点
    /// - Returns:
    private func makeClipPath(origin: CGPoint) -> UIBezierPath {
        // size: 50, 50
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 28.92, y: 8.34))
        bezierPath.addCurve(to: CGPoint(x: 28.86, y: 9.32), controlPoint1: CGPoint(x: 28.92, y: 8.67), controlPoint2: CGPoint(x: 28.9, y: 9))
        bezierPath.addLine(to: CGPoint(x: 40.68, y: 9.32))
        bezierPath.addCurve(to: CGPoint(x: 40.68, y: 21.14), controlPoint1: CGPoint(x: 40.68, y: 9.32), controlPoint2: CGPoint(x: 40.68, y: 14.5))
        bezierPath.addCurve(to: CGPoint(x: 41.66, y: 21.08), controlPoint1: CGPoint(x: 41, y: 21.1), controlPoint2: CGPoint(x: 41.33, y: 21.08))
        bezierPath.addCurve(to: CGPoint(x: 49.5, y: 28.92), controlPoint1: CGPoint(x: 45.99, y: 21.08), controlPoint2: CGPoint(x: 49.5, y: 24.59))
        bezierPath.addCurve(to: CGPoint(x: 41.66, y: 36.76), controlPoint1: CGPoint(x: 49.5, y: 33.25), controlPoint2: CGPoint(x: 45.99, y: 36.76))
        bezierPath.addCurve(to: CGPoint(x: 40.68, y: 36.7), controlPoint1: CGPoint(x: 41.33, y: 36.76), controlPoint2: CGPoint(x: 41, y: 36.74))
        bezierPath.addCurve(to: CGPoint(x: 40.68, y: 49.5), controlPoint1: CGPoint(x: 40.68, y: 43.8), controlPoint2: CGPoint(x: 40.68, y: 49.5))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 49.5))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 36.19), controlPoint1: CGPoint(x: 0.5, y: 49.5), controlPoint2: CGPoint(x: 0.5, y: 43.53))
        bezierPath.addCurve(to: CGPoint(x: 3.44, y: 36.76), controlPoint1: CGPoint(x: 1.41, y: 36.56), controlPoint2: CGPoint(x: 2.4, y: 36.76))
        bezierPath.addCurve(to: CGPoint(x: 11.28, y: 28.92), controlPoint1: CGPoint(x: 7.77, y: 36.76), controlPoint2: CGPoint(x: 11.28, y: 33.25))
        bezierPath.addCurve(to: CGPoint(x: 9.09, y: 23.48), controlPoint1: CGPoint(x: 11.28, y: 26.81), controlPoint2: CGPoint(x: 10.45, y: 24.89))
        bezierPath.addCurve(to: CGPoint(x: 3.44, y: 21.08), controlPoint1: CGPoint(x: 7.66, y: 22), controlPoint2: CGPoint(x: 5.66, y: 21.08))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 21.65), controlPoint1: CGPoint(x: 2.4, y: 21.08), controlPoint2: CGPoint(x: 1.41, y: 21.28))
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: 9.32), controlPoint1: CGPoint(x: 0.5, y: 14.77), controlPoint2: CGPoint(x: 0.5, y: 9.32))
        bezierPath.addLine(to: CGPoint(x: 13.3, y: 9.32))
        bezierPath.addCurve(to: CGPoint(x: 13.24, y: 8.34), controlPoint1: CGPoint(x: 13.26, y: 9), controlPoint2: CGPoint(x: 13.24, y: 8.67))
        bezierPath.addCurve(to: CGPoint(x: 14.25, y: 4.49), controlPoint1: CGPoint(x: 13.24, y: 6.94), controlPoint2: CGPoint(x: 13.61, y: 5.63))
        bezierPath.addCurve(to: CGPoint(x: 21.08, y: 0.5), controlPoint1: CGPoint(x: 15.59, y: 2.11), controlPoint2: CGPoint(x: 18.15, y: 0.5))
        bezierPath.addCurve(to: CGPoint(x: 28.92, y: 8.34), controlPoint1: CGPoint(x: 25.41, y: 0.5), controlPoint2: CGPoint(x: 28.92, y: 4.01))
        bezierPath.close()
        
        bezierPath.apply(CGAffineTransform.identity.translatedBy(x: origin.x, y: origin.y))
        return bezierPath
    }
    
    /// 显示
    ///
    /// - Parameter succeed: 成功回调
    func show(succeed: @escaping SucceedCallback) {
        guard self.superview == nil else {
            return
        }
        
        self.succeedCallback = succeed
        
        if let window = UIApplication.shared.delegate?.window! {
            self.converControl = UIControl.init(frame: window.bounds)
            self.converControl?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            window.addSubview(self.converControl!)
            
            self.center = window.center
            window.addSubview(self)
        }
    }
    
    @objc func hide() {
        self.removeFromSuperview()
        self.converControl?.removeFromSuperview()
    }
}


// MARK: - SlideAreaView
fileprivate extension PLSlideVerify {
    
    class SlideAreaView: UIView {
        
        var textLabel: UILabel!
        var chunkView: UIImageView!
        var isDraging: Bool = false
        
        var dragingCallback: ((CGFloat)->Void)?
        var dragEndCallback: ((CGFloat)->Bool)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.clipsToBounds = true
            self.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            
            self.textLabel = UILabel()
            self.textLabel.frame = bounds
            self.textLabel.textColor = UIColor.lightGray
            self.textLabel.text = "向右滑动滑块完成拼图"
            self.textLabel.font = UIFont.systemFont(ofSize: 13)
            self.textLabel.textAlignment = .center
            self.addSubview(self.textLabel)
            
            self.chunkView = UIImageView()
            self.chunkView.frame = .init(x: 0, y: 0, width: bounds.height, height: bounds.height)
            self.chunkView.backgroundColor = .white
            self.addSubview(self.chunkView)

            self.chunkView.layer.borderWidth = 1
            self.chunkView.layer.borderColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let point = touches.first?.location(in: self) else {
                return
            }
            
            if self.chunkView.frame.contains(point) {
                self.isDraging = true
            }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let point = touches.first?.location(in: self) else {
                return
            }
            
            if self.isDraging {
                self.chunkView.center.x = max(bounds.height / 2, min(bounds.width - bounds.height / 2, point.x))
                
                let r = self.chunkView.frame.minX / (bounds.width - bounds.height)
                self.dragingCallback?(r)
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            guard self.isDraging else {
                return
            }
            
            self.isDraging = false
            let r = self.chunkView.frame.minX / (bounds.width - bounds.height)
            if !(self.dragEndCallback?(r) ?? false) {
                UIView.animate(withDuration: 0.25) {
                    self.chunkView.center.x = self.bounds.height / 2
                }
            }
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.isDraging = false
            UIView.animate(withDuration: 0.25) {
                self.chunkView.center.x = self.bounds.height / 2
            }
        }
    }
}
