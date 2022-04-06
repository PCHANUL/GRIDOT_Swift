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
        guard let color = UIColor.init(named: "Color1") else { return }
        gradient.frame = bounds
        gradient.colors = [
            color.withAlphaComponent(0).cgColor,
            color.withAlphaComponent(0.7).cgColor,
            color.withAlphaComponent(1).cgColor]
        layer.addSublayer(gradient)
    }
    
    func resetGradient() {
        guard let sublayers = layer.sublayers else { return }
        guard let gradient = sublayers[0] as? CAGradientLayer else { return }
        guard let color = UIColor.init(named: "Color1") else { return }
        gradient.colors = [
            color.withAlphaComponent(0).cgColor,
            color.withAlphaComponent(0.7).cgColor,
            color.withAlphaComponent(1).cgColor]
    }
}
