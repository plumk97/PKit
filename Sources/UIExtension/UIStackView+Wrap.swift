//
//  UIStackView+Wrap.swift
//  PKit
//
//  Created by Plumk on 2024/12/18.
//


import UIKit

public extension Array where Element: UIView {
    
    func wrapStackView(
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        
        let stackView = UIStackView(arrangedSubviews: self)
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        return stackView
    }
}
