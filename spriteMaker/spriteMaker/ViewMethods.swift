//
//  ViewMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/29.
//

import UIKit

// view에 그림자 생성 (마스크 비활성)
func setViewShadow(target: UIView, radius: CGFloat, opacity: Float) {
    target.layer.masksToBounds = false
    target.layer.shadowColor = UIColor.black.cgColor
    target.layer.shadowOffset = CGSize(width: 0, height: 0)
    target.layer.shadowRadius = radius
    target.layer.shadowOpacity = opacity
}

func setViewShadowWithColor(target: UIView, radius: CGFloat, opacity: Float, color: UIColor) {
    target.layer.masksToBounds = false
    target.layer.shadowColor = color.cgColor
    target.layer.shadowOffset = CGSize(width: 0, height: 0)
    target.layer.shadowRadius = radius
    target.layer.shadowOpacity = opacity
}

func setSideCorner(target: UIView, side: String, radius: CGFloat) {
    target.clipsToBounds = true
    target.layer.cornerRadius = radius
    switch side {
    case "top":
        target.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    case "bottom":
        target.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    case "left":
        target.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    case "right":
        target.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    case "all":
        return
    default:
        return
    }
}

func addInnerShadow(_ targetView: UIView, rect: CGRect, radius: CGFloat) {
    if (targetView.layer.sublayers != nil) { return }
    let innerShadow = CALayer()
    innerShadow.frame = rect
    
    let path = UIBezierPath(roundedRect: innerShadow.frame.insetBy(dx: -5, dy: -5), cornerRadius: radius)
    let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: radius).reversing()
    
    path.append(cutout)
    innerShadow.shadowPath = path.cgPath
    innerShadow.masksToBounds = true
    innerShadow.shadowColor = UIColor.black.cgColor
    innerShadow.shadowOffset = CGSize(width: 0, height: 0)
    innerShadow.shadowOpacity = 0.2
    innerShadow.shadowRadius = 5
    innerShadow.cornerRadius = radius - 10
    targetView.layer.addSublayer(innerShadow)
}
