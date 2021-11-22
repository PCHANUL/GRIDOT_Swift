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
    var cursorSize: CGFloat!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        cursorTerm = CGPoint(x: 0, y: 0)
        cursorPoint = [:]
        cursorSize = 20
    }

    func drawFingerCursor(_ context: CGContext) {
        guard let image = UIImage(named: "pointer") else { return }
        let flipedImage = flipImageVertically(originalImage: image)
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 1, color: UIColor.black.cgColor)
        context.draw(
            flipedImage.cgImage!,
            in: CGRect(x: cursorPosition.x - 1.5, y: cursorPosition.y - 0.5, width: cursorSize, height: cursorSize))
        context.fillPath()
    }
    
    func drawCursorPoint(_ context: CGContext) {
        let x: CGFloat!
        let y: CGFloat!
        
        guard let point = canvas.transPositionWithAllowRange(cursorPosition, range: 7) else { return }
        x = canvas.onePixelLength * CGFloat(point["x"]!)
        y = canvas.onePixelLength * CGFloat(point["y"]!)
        
        context.setLineWidth(1)
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 1, color: UIColor.black.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.addRect(CGRect(x: x, y: y, width: canvas.onePixelLength, height: canvas.onePixelLength))
        context.strokePath()
    }
    
    func drawFingerCursorTip(_ context: CGContext) {
        context.setShadow(offset: CGSize(), blur: 0)
        context.setFillColor(canvas.selectedColor.cgColor)
        context.addArc(
            center: cursorPosition, radius: canvas.onePixelLength / 4,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.fillPath()
    }
    
    func checkCursorIsOut(_ pos: CGPoint) {
        if (pos.x > canvas.lengthOfOneSide) {
            cursorTerm.x += canvas.lengthOfOneSide + cursorSize
        } else if (pos.x < -cursorSize) {
            cursorTerm.x -= canvas.lengthOfOneSide + cursorSize
        } else if (pos.y > canvas.lengthOfOneSide) {
            cursorTerm.y += canvas.lengthOfOneSide + cursorSize
        } else if (pos.y < -cursorSize) {
            cursorTerm.y -= canvas.lengthOfOneSide + cursorSize
        }
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
        if (canvas.activatedDrawing) {
            cursorTerm.x = canvas.moveTouchPosition.x - cursorPosition.x
            cursorTerm.y = canvas.moveTouchPosition.y - cursorPosition.y
            canvas.moveTouchPosition.x = cursorPosition.x
            canvas.moveTouchPosition.y = cursorPosition.y
        } else {
            cursorTerm.x = canvas.initTouchPosition.x - cursorPosition.x
            cursorTerm.y = canvas.initTouchPosition.y - cursorPosition.y
            canvas.moveTouchPosition.x = cursorPosition.x
            canvas.moveTouchPosition.y = cursorPosition.y
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        if (canvas.activatedDrawing == false) {
            drawCursorPoint(context)
        }
        drawFingerCursor(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        checkCursorIsOut(canvas.moveTouchPosition)
        cursorPosition.x = canvas.moveTouchPosition.x
        cursorPosition.y = canvas.moveTouchPosition.y
        if (canvas.activatedDrawing == false) {
            drawCursorPoint(context)
        }
        drawFingerCursor(context)
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}
