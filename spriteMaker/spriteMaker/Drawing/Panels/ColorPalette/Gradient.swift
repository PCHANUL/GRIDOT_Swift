//
//  Gradient.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/01.
//

import UIKit

class Gradient {
    var gl: CAGradientLayer!
    
    init(color: UIColor) {
        self.gl = CAGradientLayer()
        setColor(color: color)
    }
    
    func setColor(color: UIColor) {
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0;
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        let vSat = sat / 2
        let vBri = bri / 2
        let colorB = UIColor(
            hue: hue, saturation: min(sat - vSat, 1),
            brightness: min(bri - vBri, 1), alpha: alpha
        )
        let colorL = UIColor(
            hue: hue, saturation: min(sat + vSat, 1),
            brightness: min(bri + vBri, 1), alpha: alpha
        )
        self.gl.colors = [colorB.cgColor, colorL.cgColor]
        
        let endPointX = 0.5 - ((1 - bri) / vBri)
        self.gl.startPoint = CGPoint(x: 0, y: 0)
        self.gl.endPoint = CGPoint(x: endPointX > 0 ? endPointX : 1, y: 0)
    }
}
