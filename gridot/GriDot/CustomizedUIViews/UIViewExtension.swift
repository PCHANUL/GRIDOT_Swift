//
//  UIViewExtension.swift
//  GriDot
//
//  Created by 박찬울 on 2022/04/01.
//

import UIKit

extension UIView {
    func setGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [
            UIColor.init(white: 1, alpha: 0).cgColor,
            UIColor.init(white: 1, alpha: 0.7).cgColor,
            UIColor.white.cgColor]
        layer.addSublayer(gradient)
    }
}
