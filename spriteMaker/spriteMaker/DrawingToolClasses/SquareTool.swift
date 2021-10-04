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
    
    func addSquarePixels(_ context: CGContext, isGuideLine: Bool) {
        let startPoint = canvas.transPosition(canvas.initTouchPosition)
        let endPoint = canvas.transPosition(canvas.moveTouchPosition)
        let quadrant = canvas.lineTool.getQuadrant(start: startPoint, end: endPoint)
        var pixelPoint = startPoint
        
        while pixelPoint["x"] != endPoint["x"] {
            if isGuideLine {
                canvas.lineTool.addTouchGuideLine(context, pixelPoint, isGuideLine)
                canvas.lineTool.addTouchGuideLine(context, ["x": pixelPoint["x"]!, "y": endPoint["y"]!], isGuideLine)
            } else {
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: endPoint["y"]!)
            }
            pixelPoint["x"] = pixelPoint["x"]! + quadrant["x"]!
        }
        
        while pixelPoint["y"] != endPoint["y"] {
            if isGuideLine {
                canvas.lineTool.addTouchGuideLine(context, pixelPoint, isGuideLine)
                canvas.lineTool.addTouchGuideLine(context, ["x": startPoint["x"]!, "y": pixelPoint["y"]!], isGuideLine)
            } else {
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: startPoint["x"]!, y: pixelPoint["y"]!)
            }
            pixelPoint["y"] = pixelPoint["y"]! + quadrant["y"]!
        }
        if isGuideLine {
            canvas.lineTool.addTouchGuideLine(context, endPoint, isGuideLine)
            context.drawPath(using: .fillStroke)
            context.setShadow(offset: CGSize(), blur: 0)
        } else {
            canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: endPoint["x"]!, y: endPoint["y"]!)
        }
        
    }
}

extension SquareTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        case "touch":
            if (canvas.activatedDrawing) {
                addSquarePixels(context, isGuideLine: true)
            } else if (isTouchesEnded) {
                addSquarePixels(context, isGuideLine: false)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addSquarePixels(context, isGuideLine: true)
        case "touch":
            if (canvas.activatedDrawing) {
                addSquarePixels(context, isGuideLine: true)
            } else if (isTouchesEnded) {
                addSquarePixels(context, isGuideLine: false)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addSquarePixels(context, isGuideLine: false)
            canvas.timeMachineVM.addTime()
        case "touch":
            if (canvas.activatedDrawing == false && isTouchesEnded) {
                addSquarePixels(context, isGuideLine: false)
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
