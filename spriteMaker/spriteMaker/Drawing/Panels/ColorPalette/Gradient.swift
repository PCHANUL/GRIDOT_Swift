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
        
        self.gl.locations = [0]
        self.gl.startPoint = CGPoint(x: 0, y: 0)
        self.gl.endPoint = CGPoint(x: 1, y: 0)
    }
    
    func setColor(color: UIColor) {
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0;
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        let vSat = sat / 2, vBri = bri / 2;
        let colorB = UIColor(hue: hue, saturation: sat - vSat, brightness: bri - vBri, alpha: alpha).cgColor
        let colorL = UIColor(hue: hue, saturation: sat + vSat, brightness: bri + vBri, alpha: alpha).cgColor
        
//        let vSat = sat / 2, vBri = bri / 2;
//        let colorB = UIColor(hue: hue, saturation: max(sat - vSat, 0), brightness: max(bri - vBri, 0), alpha: alpha).cgColor
//        let colorL = UIColor(hue: hue, saturation: min(sat + vSat, 1), brightness: min(bri + vBri, 1), alpha: alpha).cgColor
        
        print(colorB, colorL)
        self.gl.colors = [colorB, color, colorL]
    }
}
