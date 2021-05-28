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

func setOneSideCorner(target: UIView, side: String) {
    if (["top", "bottom"].firstIndex(of: side) != nil) {
        target.clipsToBounds = true
        target.layer.cornerRadius = target.bounds.height / 3
        if side == "top" {
            target.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            target.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
    }
}
