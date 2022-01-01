//
//  SquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/30.
//

import UIKit

class SquareTool {
    var canvas: Canvas!
    var isTouchesEnded: Bool
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.isTouchesEnded = false
    }
    
    func addSquarePixels(_ context: CGContext, _ isGuideLine: Bool, _ isFilledSquare: Bool) {
        if (isFilledSquare) {
            drawFilledSquare(context, isGuideLine)
        } else {
            drawSquare(context, isGuideLine)
        }
    }
    
    func drawSquare(_ context: CGContext, _ isGuideLine: Bool) {
        let startPoint = canvas.transPosition(canvas.initTouchPosition)
        let endPoint = canvas.transPosition(canvas.moveTouchPosition)
        let quadrant = canvas.lineTool.getQuadrant(start: startPoint, end: endPoint)
        var pixelPoint = startPoint
        
        if (pixelPoint["x"] == endPoint["x"] || pixelPoint["y"] == endPoint["y"]) { return }
        
        while (pixelPoint["x"] != endPoint["x"]) {
            canvas.lineTool.addTouchGuideLine(context, pixelPoint, isGuideLine)
            canvas.lineTool.addTouchGuideLine(context, ["x": pixelPoint["x"]!, "y": endPoint["y"]!], isGuideLine)
            if (isGuideLine == false) {
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: endPoint["y"]!)
            }
            pixelPoint["x"] = pixelPoint["x"]! + quadrant["x"]!
        }
        
        while (pixelPoint["y"] != endPoint["y"]) {
            canvas.lineTool.addTouchGuideLine(context, pixelPoint, isGuideLine)
            canvas.lineTool.addTouchGuideLine(context, ["x": startPoint["x"]!, "y": pixelPoint["y"]!], isGuideLine)
            if (isGuideLine == false) {
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: startPoint["x"]!, y: pixelPoint["y"]!)
            }
            pixelPoint["y"] = pixelPoint["y"]! + quadrant["y"]!
        }
        
        canvas.lineTool.addTouchGuideLine(context, endPoint, isGuideLine)
        context.drawPath(using: .fillStroke)
        context.setShadow(offset: CGSize(), blur: 0)
        if (isGuideLine == false) {
            canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: endPoint["x"]!, y: endPoint["y"]!)
        }
    }
    
    func drawFilledSquare(_ context: CGContext, _ isGuideLine: Bool) {
        let startPoint = canvas.transPosition(canvas.initTouchPosition)
        let endPoint = canvas.transPosition(canvas.moveTouchPosition)
        let quadrant = canvas.lineTool.getQuadrant(start: startPoint, end: endPoint)
        var pixelPoint = startPoint
        
        while (pixelPoint["y"] != endPoint["y"]! + quadrant["y"]!) {
            while (pixelPoint["x"] != endPoint["x"]! + quadrant["x"]!) {
                canvas.lineTool.addTouchGuideLine(context, pixelPoint, isGuideLine)
                if (isGuideLine == false) {
                    canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                }
                pixelPoint["x"] = pixelPoint["x"]! + quadrant["x"]!
            }
            pixelPoint["y"] = pixelPoint["y"]! + quadrant["y"]!
            pixelPoint["x"] = startPoint["x"]!
        }
        
        context.drawPath(using: .fillStroke)
        context.setShadow(offset: CGSize(), blur: 0)
    }
}

extension SquareTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext, isFilledSquare: Bool) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        case "touch":
            if (canvas.activatedDrawing) {
                addSquarePixels(context, true, isFilledSquare)
            } else if (isTouchesEnded) {
                addSquarePixels(context, false, isFilledSquare)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func touchesMoved(_ context: CGContext, isFilledSquare: Bool) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addSquarePixels(context, true, isFilledSquare)
        case "touch":
            if (canvas.activatedDrawing) {
                addSquarePixels(context, true, isFilledSquare)
            } else if (isTouchesEnded) {
                addSquarePixels(context, false, isFilledSquare)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext, isFilledSquare: Bool) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addSquarePixels(context, false, isFilledSquare)
            canvas.timeMachineVM.addTime()
        case "touch":
            if (canvas.activatedDrawing == false && isTouchesEnded) {
                addSquarePixels(context, false, isFilledSquare)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func buttonUp() {
        isTouchesEnded = true
    }
}
