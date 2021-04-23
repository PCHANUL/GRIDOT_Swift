//
//  TriangleCornerView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/23.
//

import UIKit

class TriangleCornerView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let pos = rect.maxX
        
        context.beginPath()
        context.move(to: CGPoint(x: pos, y: pos * 0.85))
        context.addLine(to: CGPoint(x: pos, y: pos))
        context.addLine(to: CGPoint(x: pos * 0.85, y: pos))
        context.addLine(to: CGPoint(x: pos, y: pos * 0.85))
        context.closePath()

        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
}
