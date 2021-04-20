//
//  DrawingEraser.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

class EraserTool {
    var canvas: Canvas!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
    }
    
    func drawEraser(_ context: CGContext) {
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(3)
        context.addArc(center: canvas.moveTouchPosition, radius: canvas.onePixelLength / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.strokePath()
        
        context.setFillColor(UIColor.white.cgColor)
        context.addArc(center: canvas.moveTouchPosition, radius: canvas.onePixelLength / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.fillPath()
    }
    
}
