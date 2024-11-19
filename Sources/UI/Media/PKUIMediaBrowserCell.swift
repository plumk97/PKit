//
//  PKUIMediaBrowserCell.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import UIKit
import Photos

class PKUIMediaBrowserCell: UICollectionViewCell {
    
    var media: PKUIMedia? {
        didSet {
            self.reloadData()
        }
    }
    
    var page: PKUIMediaBrowserPage?
    
    func reloadData() {
        guard let media = self.media else {
            return
        }
        self.page?.removeFromSuperview()
        
        let page = media.pk_pageClass.init(frame: .zero)
        page.setMedia(media)
        self.page = page
        self.contentView.addSubview(page)
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let page = self.page else {
            return
        }
        page.frame = .init(x: 0, y: 0, width: self.contentView.bounds.width - 10, height: self.contentView.bounds.height)
    }
}
