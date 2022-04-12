//
//  TouchDrawingMode.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/21.
//

import UIKit

class TouchDrawingMode: NSObject {
    var canvas: Canvas!
    var cursorTerm: CGPoint!
    var cursorImage: UIImage!
    var cursorName: String!
    var cursorPosition: CGPoint!
    var cursorSize: CGFloat!
    var cursorDrawPosition: CGPoint!
    var cursorDrawSize: CGFloat!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        cursorTerm = CGPoint(x: 0, y: 0)
        cursorImage = flipImageVertically(originalImage: UIImage(named: "Cursor_finger")!)
        cursorName = "default"
        cursorPosition = canvas.initTouchPosition
        cursorSize = 20
        cursorDrawPosition = CGPoint(x: 0, y: 0)
        cursorDrawSize = 0
    }

    func drawFingerCursor(_ context: CGContext) {
        let x = cursorPosition.x + cursorDrawPosition.x
        let y = cursorPosition.y + cursorDrawPosition.y
        let width = cursorSize! + cursorDrawSize
        let height = cursorSize! + cursorDrawSize
        
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 1, color: UIColor.black.cgColor)
        context.draw(cursorImage.cgImage!, in: CGRect(x: x, y: y, width: width, height: height))
        context.fillPath()
    }
    
    func drawPointedPixel(_ context: CGContext) {
        guard let point = canvas.transPositionWithAllowRange(cursorPosition, range: 7) else { return }
        let x = canvas.onePixelLength * point.x
        let y = canvas.onePixelLength * point.y
        
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
    
    func changeCursorSelectedDrawingTool() {
        var imageName: String
        
        cursorDrawPosition = CGPoint(x: 0, y: 0)
        cursorDrawSize = 0
        switch canvas.selectedDrawingTool {
        case "Eraser", "Paint", "Pencil":
            imageName = "Cursor_\(canvas.selectedDrawingTool!)"
            cursorDrawPosition.y -= cursorSize + 5
            cursorDrawSize += 5
        case "Magic":
            imageName = "Cursor_\(canvas.selectedDrawingTool!)"
            cursorDrawSize += 10
        case "Hand":
            imageName = canvas.activatedDrawing ? "Cursor_Hold" : "Cursor_Hand"
            cursorDrawSize += 5
        default:
            imageName = "Cursor_Finger"
        }

        cursorName = canvas.selectedDrawingTool
        cursorImage = flipImageVertically(originalImage: UIImage(named: imageName)!)
        if (canvas.drawingVC.currentSide == .right) {
            cursorImage = flipImageHorizontal(originalImage: cursorImage)
            cursorDrawPosition.x -= cursorSize + 5
        }
    }
}

extension TouchDrawingMode {
    func setInitPosition() {
        cursorPosition = canvas.initTouchPosition
    }
    
    func noneTouches(_ context: CGContext) {
        changeCursorSelectedDrawingTool()
        drawPointedPixel(context)
        drawFingerCursor(context)
    }
    
    func touchesBegan(_ pixelPos: CGPoint) {
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
        changeCursorSelectedDrawingTool()
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
