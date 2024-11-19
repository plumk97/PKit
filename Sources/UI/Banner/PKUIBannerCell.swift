//
//  PKUIBannerCell.swift
//  PKit-Core-JSON-UI-Util
//
//  Created by Plumk on 2023/9/5.
//

import UIKit

open class PKUIBannerCell: UICollectionViewCell {
    
    public let imageView = UIImageView()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    open func commInit() {
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
}
