//
//  TouchDrawingMode.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/21.
//

import UIKit

class TouchDrawingMode: NSObject {
    var canvas: Canvas!
    var cursorPosition: CGPoint!
    var cursorTerm: CGPoint!
    var cursorPoint: [String: Int]
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        cursorTerm = CGPoint(x: 0, y: 0)
        cursorPoint = [:]
    }

    func drawFingerCursor(_ context: CGContext) {
        let position: CGPoint!
        position = CGPoint(
            x: cursorPosition.x + cursorTerm.x,
            y: cursorPosition.y + cursorTerm.y
        )
//        context.setShadow(offset: CGSize(), blur: 0)
//        context.setFillColor(canvas.selectedColor.cgColor)
//        context.addArc(center: position, radius: canvas.onePixelLength / 4, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
//        context.fillPath()
        
        guard let image = UIImage(named: "finger") else { return }
        let flipedImage = canvas.flipImageVertically(originalImage: image)
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 10)
        context.draw(flipedImage.cgImage!, in: CGRect(x: position.x - 1.5, y: position.y - 0.5, width: 20, height: 20))
        context.fillPath()
    }
    
    func drawCursorPoint(_ context: CGContext) {
        let position: CGPoint!
        let x: CGFloat!
        let y: CGFloat!
        
        position = CGPoint(
            x: cursorPosition.x + cursorTerm.x,
            y: cursorPosition.y + cursorTerm.y
        )
        guard let point = canvas.transPositionWithAllowRange(position, range: 7) else { return }
        x = canvas.onePixelLength * CGFloat(point["x"]!)
        y = canvas.onePixelLength * CGFloat(point["y"]!)
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        context.addRect(CGRect(x: x, y: y, width: canvas.onePixelLength, height: canvas.onePixelLength))
        context.strokePath()
    }
}

extension TouchDrawingMode {
    func setInitPosition() {
        cursorPosition = canvas.initTouchPosition
    }
    
    func noneTouches(_ context: CGContext) {
        drawCursorPoint(context)
        drawFingerCursor(context)
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
        cursorTerm.x = canvas.moveTouchPosition.x - canvas.initTouchPosition.x
        cursorTerm.y = canvas.moveTouchPosition.y - canvas.initTouchPosition.y
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawFingerCursor(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        cursorTerm.x = canvas.moveTouchPosition.x - canvas.initTouchPosition.x
        cursorTerm.y = canvas.moveTouchPosition.y - canvas.initTouchPosition.y
        drawCursorPoint(context)
        drawFingerCursor(context)
    }
    
    func touchesEnded(_ context: CGContext) {
        cursorPosition.x = cursorPosition.x + cursorTerm.x
        cursorPosition.y = cursorPosition.y + cursorTerm.y
        cursorTerm = CGPoint(x: 0, y: 0)
    }
}
