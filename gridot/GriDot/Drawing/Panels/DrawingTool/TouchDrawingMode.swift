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
        var imageName: String
        var image: UIImage
        var x = cursorPosition.x
        var y = cursorPosition.y
        var width = cursorSize!
        var height = cursorSize!
        
        switch canvas.selectedDrawingTool {
        case "Eraser", "Paint", "Pencil":
            imageName = "Cursor_\(canvas.selectedDrawingTool!)"
            y -= cursorSize + 5
            width += 5
            height += 5
        case "Magic":
            imageName = "Cursor_\(canvas.selectedDrawingTool!)"
            width += 10
            height += 10
        case "Hand":
            imageName = canvas.handTool.isHolded ? "Cursor_Hold" : "Cursor_Hand"
        default:
            imageName = "Cursor_Finger"
        }
        
        image = flipImageVertically(originalImage: UIImage(named: imageName)!)
        if (canvas.drawingVC.currentSide == "right") {
            image = flipImageHorizontal(originalImage: image)
            x -= cursorSize + 5
        }
        
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 1, color: UIColor.black.cgColor)
        context.draw(image.cgImage!, in: CGRect(x: x, y: y, width: width, height: height))
        context.fillPath()
    }
    
    func drawPointedPixel(_ context: CGContext) {
        guard let point = canvas.transPositionWithAllowRange(cursorPosition, range: 7) else { return }
        let x = canvas.onePixelLength * CGFloat(point["x"]!)
        let y = canvas.onePixelLength * CGFloat(point["y"]!)
        
        context.setLineWidth(1)
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 1, color: UIColor.black.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.addRect(CGRect(x: x, y: y, width: canvas.onePixelLength, height: canvas.onePixelLength))
        context.strokePath()
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
        drawPointedPixel(context)
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
        if (canvas.activatedDrawing == false && canvas.selectedDrawingTool != "Eraser") {
            drawPointedPixel(context)
        }
        drawFingerCursor(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        checkCursorIsOut(canvas.moveTouchPosition)
        cursorPosition.x = canvas.moveTouchPosition.x
        cursorPosition.y = canvas.moveTouchPosition.y
        if (canvas.activatedDrawing == false && canvas.selectedDrawingTool != "Eraser") {
            drawPointedPixel(context)
        }
        drawFingerCursor(context)
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}
