//
//  UIViewChangesHeight.swift
//  GriDot
//
//  Created by 박찬울 on 2022/04/01.
//

import UIKit

class UIViewChangesHeight: UIView {
    var heightConstraint: NSLayoutConstraint!
    var maxHeight: CGFloat!
    var minHeight: CGFloat!
    var prevPoint: CGFloat!
    
    func initHeightConstrant(minHeight: CGFloat, maxHeight: CGFloat) {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: frame.height)
        heightConstraint.priority = UILayoutPriority(1000)
        heightConstraint.isActive = true
        prevPoint = minHeight
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    func setViewHeight(_ point: CGFloat) {
        if (heightConstraint == nil) { return }
        if (heightConstraint.constant == maxHeight && point < minHeight) { return }
        if (heightConstraint.constant == minHeight && point > maxHeight) { return }
        
        let acc = prevPoint - point
        let newHeight = self.frame.height + acc
        
        if (newHeight > minHeight && newHeight < maxHeight) {
            heightConstraint.constant = newHeight
        } else if (newHeight < minHeight) {
            heightConstraint.constant = minHeight
        } else if (newHeight > maxHeight) {
            heightConstraint.constant = maxHeight
        }
        prevPoint = point
    }
}
