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

func setOneSideCorner(target: UIView, side: String, radius: CGFloat) {
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
