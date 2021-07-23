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
        let position: CGPoint!
        
        position = (canvas.selectedDrawingMode == "touch") ? canvas.touchDrawingMode.cursorPosition : canvas.moveTouchPosition
        context.setShadow(offset: CGSize(), blur: 0)
        context.setFillColor(canvas.selectedColor.cgColor)
        context.addArc(center: position, radius: canvas.onePixelLength / 4, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.fillPath()
    }
}

extension PencilTool {
    func noneTouches(_ context: CGContext) {
        drawAnchor(context)
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawAnchor(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        drawAnchor(context)
        if (canvas.activatedDrawing) {
            drawPixel(context)
        }
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}

