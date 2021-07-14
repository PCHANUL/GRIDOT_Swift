//
//  PencilTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/27.
//

import UIKit

class PencilTool {
    var canvas: Canvas!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
    }
    
    func drawPixel(_ context: CGContext) {
        guard let point = canvas.transPositionWithAllowRange(canvas.moveTouchPosition, range: 7) else { return }
        canvas.selectPixel(pixelPosition: point)
    }
    
    func drawAnchor(_ context: CGContext) {
        guard let image = UIImage(named: "PencilAnchor") else { return }
        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 10)
        context.draw(image.cgImage!, in: CGRect(x: canvas.moveTouchPosition.x + 5, y: canvas.moveTouchPosition.y - 30, width: 25, height: 25))
        context.fillPath()
        
        context.setShadow(offset: CGSize(), blur: 0)
        context.setFillColor(canvas.selectedColor.cgColor)
        context.addArc(center: canvas.moveTouchPosition, radius: canvas.onePixelLength / 4, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.fillPath()
    }
}

extension PencilTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawAnchor(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        drawPixel(context)
        drawAnchor(context)
    }
    
    func touchesEnded(_ context: CGContext) {
        canvas.timeMachineVM.addTime()
    }
}

