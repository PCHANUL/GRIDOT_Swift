//
//  SquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/30.
//

import UIKit

class SquareTool {
    var canvas: Canvas!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
    }
    
    func addSquarePixels(_ context: CGContext, isGuideLine: Bool) {
        let startPoint = canvas.transPosition(canvas.initTouchPosition)
        let endPoint = canvas.transPosition(canvas.moveTouchPosition)
        let quadrant = canvas.lineTool.getQuadrant(start: startPoint, end: endPoint)
        var pixelPoint = startPoint
        
        while pixelPoint["x"] != endPoint["x"] {
            if isGuideLine {
                canvas.lineTool.addTouchGuideLine(context, pixelPoint)
                canvas.lineTool.addTouchGuideLine(context, ["x": pixelPoint["x"]!, "y": endPoint["y"]!])
            } else {
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: endPoint["y"]!)
            }
            pixelPoint["x"] = pixelPoint["x"]! + quadrant["x"]!
        }
        
        while pixelPoint["y"] != endPoint["y"] {
            if isGuideLine {
                canvas.lineTool.addTouchGuideLine(context, pixelPoint)
                canvas.lineTool.addTouchGuideLine(context, ["x": startPoint["x"]!, "y": pixelPoint["y"]!])
            } else {
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: pixelPoint["x"]!, y: pixelPoint["y"]!)
                canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: startPoint["x"]!, y: pixelPoint["y"]!)
            }
            pixelPoint["y"] = pixelPoint["y"]! + quadrant["y"]!
        }
        if isGuideLine {
            canvas.lineTool.addTouchGuideLine(context, endPoint)
            canvas.lineTool.drawTouchGuideLine(context)
        } else {
            canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: endPoint["x"]!, y: endPoint["y"]!)
        }
        
    }
}

extension SquareTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        canvas.selectPixel(pixelPosition: canvas.transPosition(canvas.initTouchPosition))
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
    }
    
    func touchesMoved(_ context: CGContext) {
        addSquarePixels(context, isGuideLine: true)
    }
    
    func touchesEnded(_ context: CGContext) {
        addSquarePixels(context, isGuideLine: false)
    }
}
